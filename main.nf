#!/usr/bin/env nextflow

import groovy.json.*

if(params.help) {
    usage = file("$baseDir/USAGE")

    cpu_count = Runtime.runtime.availableProcessors()
    bindings = ["cpu_count":"$cpu_count",
                ]

    engine = new groovy.text.SimpleTemplateEngine()
    template = engine.createTemplate(usage.text).make(bindings)

    print template.toString()
    return
}

log.info "Registration pipeline"
log.info "==================="
log.info ""
log.info "Start time: $workflow.start"
log.info ""

log.debug "[Command-line]"
log.debug "$workflow.commandLine"
log.debug ""

log.info "[Git Info]"
log.info "$workflow.repository - $workflow.revision [$workflow.commitId]"
log.info ""

log.info "[Inputs]"
log.info "Root: $params.input"
log.info "Template: $params.template"
log.info "Output directory: $params.output_dir"
log.info ""

workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
}

if (!params.input){
    error "Error ~ Please use --input for the input data."
}

if (!params.template){
    error "Error ~ Please use --template for the template."
}

root = file(params.input)

Channel.fromPath(file(params.template))
    .into {template_for_registration; template_for_transformation_nii; template_for_transformation_trk}

trk_for_transformation = Channel
    .fromFilePairs("$root/**/*.trk",
                   size:-1,
                   maxDepth:1,
                   flat: true) {it.parent.name}

Channel
    .fromPath("$root/**/*.nii.gz",
              maxDepth:1)
    .branch {
        t1: it =~ "t1.nii.gz"
        other: true
    }
    .set { result }

result.t1
.map{[it.parent.name, it]}
.into { t1_for_registration; check_subjects_number }

result.other
.map{[it.parent.name, it]}
.set { nii_for_transformation }

t1_for_registration
    .combine(template_for_registration)
    .set {t1_and_template_for_registration}


check_subjects_number.count().set{ number_subj_for_null_check }

number_subj_for_null_check
.subscribe{a -> if (a == 0)
    error "Error ~ No subjects found. Please check the naming convention, your --input path or your BIDS folder."}

process README {
    cpus 1
    publishDir = params.Readme_Publish_Dir
    tag = "README"

    output:
    file "readme.txt"

    script:
    String list_options = new String();
    for (String item : params) {
        list_options += item + "\n"
    }
    """
    echo "Registration-flow pipeline\n" >> readme.txt
    echo "Start time: $workflow.start\n" >> readme.txt
    echo "[Command-line]\n$workflow.commandLine\n" >> readme.txt
    echo "[Git Info]\n" >> readme.txt
    echo "$workflow.repository - $workflow.revision [$workflow.commitId]\n" >> readme.txt
    echo "[Options]\n" >> readme.txt
    echo "$list_options" >> readme.txt
    """
}

process Register_T1 {
    cpus params.processes

    input:
    set sid, file(t1), file(template) from t1_and_template_for_registration

    output:
    set sid, "${sid}__output0GenericAffine.mat"  into transformation_for_nii, transformation_for_trk
    file "${sid}__t1_transformed.nii.gz"
    script:
    """
    antsRegistrationSyN.sh -d 3 -m ${t1} -f ${template} -n ${params.processes} -o "${sid}__output" -t a
    mv ${sid}__outputWarped.nii.gz ${sid}__t1_transformed.nii.gz
    """
}

nii_for_transformation
    .join(transformation_for_nii)
    .combine(template_for_transformation_nii)
    .set{nii_and_template_for_transformation}

process Transform_NII {
    cpus 1

    input:
    set sid, file(nii), file(transfo), file(template) from nii_and_template_for_transformation

    output:
    file "*_transformed.nii.gz"

    script:
    """
    antsApplyTransforms -d 3 -i $nii -r $template -t $transfo -o ${nii.getSimpleName()}_transformed.nii.gz
    """
}

trk_for_transformation
    .join(transformation_for_trk)
    .combine(template_for_transformation_trk)
    .set{trk_and_template_for_transformation}

process Transform_TRK {
    cpus 1

    input:
    set sid, file(trk), file(transfo), file(template) from trk_and_template_for_transformation

    output:
    file "*_transformed.trk"

    script:
    """
    scil_apply_transform_to_tractogram.py $trk $template $transfo ${trk.getSimpleName()}_transformed.trk --remove_invalid --inverse
    """
}

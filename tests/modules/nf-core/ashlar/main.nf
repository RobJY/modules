#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ASHLAR } from '../../../../modules/nf-core/ashlar/main.nf'
include { ASHLAR as ASHLAR_TILE } from '../../../../modules/nf-core/ashlar/main.nf'

// we zero out the UUID of output tiff images with ZERO_UUID so we get a consistent md5sum
include { ZERO_UUID } from './zero_uuid.nf'
include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

params.validationSkipDuplicateCheck = true

if (params.help) {
    log.info paramsHelp("nextflow run -plugins nf-validation --help")
    exit 0
}

if (params.validate_params) {
    validateParameters()
    exit 0
}

workflow test_ashlar_sheet {

    Channel.fromSamplesheet("input")
        .map {
            it ->
                meta = [id: it[0], args: ""]
                file_list_str = it[1].split(' ')
                def file_list_file = file_list_str.collect { x -> file(x) }
                [ meta, file_list_file ]
        }
        .set { input_maps }

    ASHLAR ( input_maps, [], [] )

    ch_offset = Channel.from("8390123", "16779883")

    ASHLAR.out[0]
        .map {
            it ->
                out_file = [ it[1] ]
        }
        .merge(ch_offset)
        .set { ch_zero_uuid_input }

    ZERO_UUID ( ch_zero_uuid_input )
}

//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv
    chunk // value: integer (number of chunk to create)

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it, chunk) }
        .set { reads }

    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row, chunk) {
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    if (!file(row.bam).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> BAM file does not exist!\n${row.bam}"
    }

    if (!file(row.pbi).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> PBI file does not exist!\n${row.pbi}"
    }

    def array = []
    for ( i = 1 ; i <= chunk ; i++ ) {
        array << [ meta, file(row.bam), file(row.pbi) ]
    }

    return array
}

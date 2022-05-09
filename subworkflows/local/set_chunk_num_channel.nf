//
// Count number of samples in sampleSheet and create channel
//

workflow SET_CHUNK_NUM_CHANNEL {
    take:
    samplesheet // file: /path/to/samplesheet.csv
    chunk       // value: integer (number of chunk to create)

    main:
    println("DEBUG: $samplesheet")
    if (samplesheet =~ /^http/) {
        println("DEBUG: URL")
        String charset = "UTF-8"
        URLConnection connection = new URL(samplesheet).openConnection()
        connection.addRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)")
        connection.setRequestProperty("Accept-Charset", charset)
        InputStream response = connection.getInputStream()
        BufferedReader reader = new  BufferedReader(new InputStreamReader(response,charset)
    } else {
        println("DEBUG: TXT")
        BufferedReader reader = new BufferedReader(new FileReader(samplesheet));
    }

    int n_samples = 0;
    while (reader.readLine() != null) n_samples++;
    n_samples--;
    reader.close();

    Channel // Prepare the pbccs chunk_num channel
        .from((1..chunk).step(1).toList()*n_samples)
        .set { chunk_num }

    emit:
    chunk_num
}

# Setup to reproduce a HBase Zstd issue

A simple setup to reproduce a possible compatibility issue with Zstd compression. See
also [HBASE-27706](https://issues.apache.org/jira/browse/HBASE-27706).

---

# Steps to reproduce:

Start the containers with `docker compose up -d`. This will also build Hadoop and HBase images.

Then test that compression works:

        ./sbin/compression-check.sh

Create the initial data in HBase with the command below. It sets up a simple table with some splits and test data.

        ./sbin/setup-data.sh

Then check whether the data can be read with the following script:

        ./sbin/check-data.sh

This should show something like:

        Checking if data is available
        ...
        bar column=cf2:bar, timestamp=2023-03-15T09:14:44.108, value=bar
        baz column=cf1:baz, timestamp=2023-03-15T09:14:44.151, value=baz
        foo column=cf1:foo, timestamp=2023-03-15T09:14:43.979, value=foo
        qux column=cf3:qux, timestamp=2023-03-15T09:14:44.197, value=qux
        
        🎉

Then uncomment the built-in ZstdCodec to switch from libhadoop to the zstd-jni implementation in `hbase-site.xml` :

        <property>
            <name>hbase.io.compress.zstd.codec</name>
            <value>org.apache.hadoop.hbase.io.compress.zstd.ZstdCodec</value>
        </property>

And restart the HBase nodes with:

        docker compose restart hbase-master-1 hbase-master-2 hbase-region-server-1 hbase-region-server-2 hbase-region-server-3

The logs of the region servers will have errors such as:

        hbase-region-server-1  | 2023-03-15 09:24:49,116 WARN  [RS_OPEN_REGION-regionserver/hbase-region-server-1:16020-1] handler.AssignRegionHandler (AssignRegionHandler.java:cleanUpAndReportFailure(81)) - Failed to open region ns:tbl,c,1678871681484.13311ea91ec32f5bab90c14e9ad64538., will report to master
        hbase-region-server-1  | java.io.IOException: java.io.IOException: org.apache.hadoop.hbase.io.hfile.CorruptHFileException: Problem reading data index and meta index from file hdfs://hdfs-name-node-1:9000/hbase/data/ns/tbl/13311ea91ec32f5bab90c14e9ad64538/cf3/97412a492a4d484485110a71565ee2c4
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.HRegion.initializeStores(HRegion.java:1148)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.HRegion.initializeStores(HRegion.java:1091)
        ...
        hbase-region-server-1  | Caused by: java.io.IOException: org.apache.hadoop.hbase.io.hfile.CorruptHFileException: Problem reading data index and meta index from file hdfs://hdfs-name-node-1:9000/hbase/data/ns/tbl/13311ea91ec32f5bab90c14e9ad64538/cf3/97412a492a4d484485110a71565ee2c4
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.StoreEngine.openStoreFiles(StoreEngine.java:288)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.StoreEngine.initialize(StoreEngine.java:338)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.HStore.<init>(HStore.java:297)
        ...
        hbase-region-server-1  | Caused by: org.apache.hadoop.hbase.io.hfile.CorruptHFileException: Problem reading data index and meta index from file hdfs://hdfs-name-node-1:9000/hbase/data/ns/tbl/13311ea91ec32f5bab90c14e9ad64538/cf3/97412a492a4d484485110a71565ee2c4
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.hfile.HFileInfo.initMetaAndIndex(HFileInfo.java:392)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.HStoreFile.open(HStoreFile.java:394)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.regionserver.HStoreFile.initReader(HStoreFile.java:518)
        ...
        hbase-region-server-1  | Caused by: java.io.IOException: Premature EOF from inputStream, but still need 34 bytes
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.util.BlockIOUtils.readFullyWithHeapBuffer(BlockIOUtils.java:153)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.encoding.HFileBlockDefaultDecodingContext.prepareDecoding(HFileBlockDefaultDecodingContext.java:104)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.hfile.HFileBlock.unpack(HFileBlock.java:644)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.hfile.HFileBlock$FSReaderImpl$1.nextBlock(HFileBlock.java:1397)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.hfile.HFileBlock$FSReaderImpl$1.nextBlockWithBlockType(HFileBlock.java:1407)
        hbase-region-server-1  | 	at org.apache.hadoop.hbase.io.hfile.HFileInfo.initMetaAndIndex(HFileInfo.java:365)
        hbase-region-server-1  | 	... 10 more

Running `sbin/check-data.sh` will fail with `NotServingRegionException`s.

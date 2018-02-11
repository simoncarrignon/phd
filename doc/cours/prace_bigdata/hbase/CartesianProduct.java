// Standard classes
import java.io.IOException; 
import java.util.Vector; 
import java.util.ArrayList; 

// HBase classes
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.mapreduce.TableMapReduceUtil;
import org.apache.hadoop.hbase.mapreduce.TableMapper;
import org.apache.hadoop.hbase.mapreduce.TableReducer;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.hbase.mapreduce.TableSplit;
import org.apache.hadoop.hbase.TableName;

// Hadoop classes
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer.Context;

public class CartesianProduct extends Configured implements Tool { 
       
       // These are three global variables, which coincide with the three parameters in the call
       public static String inputTable1;
	   public static String inputTable2;
       private static String outputTable;


//=================================================================== Main
        /* 
            Explanation: Assume we want to do the cartesian product of tuples stored in two HBase tables (inputTable1 and inputTable2).             
            
            First, the main method checks the call parameters. There must be 4:
            1.- First (external) HBase input table where to read data from (it must have been created beforehand, as we will see later)
			2.- Second (internal) HBase input table where to read data from (it must have been created beforehand, as we will see later)
            4.- The HBase output table (it will be created, as we will see later)
            5.- A random value 
            
            Assume a call like this:

            yarn jar myJarFile.jar CartesianProduct Username_InputTable1 Username_InputTable2 Username_OutputTable 10
            
            Assume now the following HBase tables:
			
			- The Username_InputTable1 HBase table containing the following data:
				'key1', 'AAA'
				'key2', 'BBB'
			
			- The Username_InputTable2 HBase table containing the following data:			
				'key3', 'CCC'
				'key4', 'DDD'                 
            
            As we will see later in the map and reduce methods, what we want to do is to join all tuples from Username_InputTable1 with all the tuples from Username_InputTable2 (but those from the same table must not be joined).       
            Next, the main calls the checkIOTables method, which connects with HBase and handles it.
            Finally, the MapReduce task is run (and the run method is called).
       */
       
       public static void main(String[] args) throws Exception { 
         if (args.length<4) {
           System.err.println("Parameters missing: 'inputTableEXT inputTableINT outputTable hashValue'");
           System.exit(1);
         }
         inputTable1 = args[0];
		 inputTable2 = args[1];
         outputTable = args[2];

		 
		 
         int tablesRight = checkIOTables(args);
         if (tablesRight==0) {
           int ret = ToolRunner.run(new CartesianProduct(), args); 
           System.exit(ret); 
         } else { 
           System.exit(tablesRight); 
         }
       } 


//============================================================== checkTables

        // Explanation: Handles HBase and its relationship with the MapReduce task

       private static int checkIOTables(String [] args) throws Exception { 
         // Obtain HBase's configuration
         Configuration config = HBaseConfiguration.create();
         // Create an HBase administrator
         HBaseAdmin hba = new HBaseAdmin(config);

         /* With an HBase administrator we check if the input tables exist.
            You can modify this bit and create it here if you want. */
         if (!hba.tableExists(inputTable1)) {
           System.err.println("Input table 1 does not exist");
           return 2;
         }
		 if (!hba.tableExists(inputTable2)) {
           System.err.println("Input table 2 does not exist");
           return 2;
         }
         /* Check whether the output table exists. 
            Just the opposite as before, we do create the output table.
            Normally, MapReduce tasks attack an existing table (not created on the fly) and 
            they store the result in a new table. */
         if (hba.tableExists(outputTable)) {
           System.err.println("Output table already exists");
           return 3;
         }
         // If you want to insert data through the API, do it here
         // -- Inserts    
         /*             
                     HTable table = new HTable(config, inputTable);
                	 //You may not need this, but if batch loading, set the recovery manager to Not Force (setAutoFlush false) and deactivate the WAL
                     //table.setAutoFlush(false); --This is needed to avoid HBase to flush at every put (instead, it will buffer them and flush when told by using FlushCommits)
                     //put.setWriteToWAL(false); --This is to deactivate the Write Ahead Logging 	                        
                     Put put = new Put(Bytes.toBytes("key1")); //creates a new row with key 'key1'
	    			 put.add(Bytes.toBytes("Family"), Bytes.toBytes("Attribute"), Bytes.toBytes("Value")); //Add an attribute named Attribute that belongs to the family Family with value Value
                     table.put(put); // Inserts data
                     
                     //If you do it through the HBase Shell, this is equivalent to:
                     //put 'Username_InputTable1', 'key1', 'Family:Attribute', 'Value'                   
         */
         // -- Inserts
         // Get an HBase descriptors pointing at the input tables (the HBase descriptors handle the tables' metadata)
         HTableDescriptor htdInput1 = hba.getTableDescriptor(inputTable1.getBytes());
		 HTableDescriptor htdInput2 = hba.getTableDescriptor(inputTable2.getBytes());
		 
         // Get an HBase descriptor pointing at the new table 
         HTableDescriptor htdOutput = new HTableDescriptor(outputTable.getBytes());
		 
         // We copy the structure of the input tables in the output one by adding the input columns to the new table
         for(byte[] key: htdInput1.getFamiliesKeys()) {
		   System.out.println("family-t1 = "+ new String(key));
           htdOutput.addFamily(new HColumnDescriptor(key));
         }
		 for(byte[] key: htdInput2.getFamiliesKeys()) {
           System.out.println("family-t2 = "+ new String(key));
		   htdOutput.addFamily(new HColumnDescriptor(key));
         }		 	
		   
         //Create the new output table based on the descriptor we have been configuring
         hba.createTable(htdOutput);
         return 0;
	}


//============================================================== Job config
       //Create a new job to execute. This is called from the main and starts the MapReduce job 
       public int run(String [] args) throws Exception { 

         //Create a new MapReduce configuration object.
         Job job = new Job(HBaseConfiguration.create());
         //Set the MapReduce class
         job.setJarByClass(CartesianProduct.class);
         //Set the job name
         job.setJobName("CartesianProduct");
         // To pass parameters to the mapper and reducer we must use the setStrings of the Configuration object
		 // We pass the names of two input tables as External and Internal tables of the Cartesian product, and a hash random value. 
         job.getConfiguration().setStrings("External", inputTable1);
         job.getConfiguration().setStrings("Internal", inputTable2);
         job.getConfiguration().setInt("Hash", Integer.parseInt(args[3]));
		 System.out.println("Hash = " + args[3]); 
		 
         /* Set the Map and Reduce function:
            These are special mapper and reducers, which are prepared to read and store data on HBase tables								 
		 */
		 
		 
		 
		
		 // To initialize the mapper, we need to provide two Scan objects (ArrayList of two Scan objects) for two input tables, as follows.		 
		 ArrayList scans = new ArrayList();
 
		 Scan scan1 = new Scan();
		 System.out.println("inputTable1: "+inputTable1);
		 
		 scan1.setAttribute("scan.attributes.table.name", Bytes.toBytes(inputTable1));
		 scans.add(scan1);

		 Scan scan2 = new Scan();
		 System.err.println("inputTable2: "+inputTable2);
		 scan2.setAttribute("scan.attributes.table.name", Bytes.toBytes(inputTable2));
		 
		 scans.add(scan2);
		 
		 
         TableMapReduceUtil.initTableMapperJob(scans, Mapper.class, Text.class, Text.class, job);
         TableMapReduceUtil.initTableReducerJob(outputTable, Reducer.class, job);
     
         //Then we wait until the MapReduce task finishes? (block the program)
         boolean success = job.waitForCompletion(true); 
         return success ? 0 : 1; 
       } 


//=================================================================== Mapper

       /* This is the mapper class, which implements the map method. 
          The MapReduce framework will call this method automatically when needed.
          Note its header defines the input key-value and an object where to store the resulting key-values produced in the map.
          - ImmutableBytesWritable rowMetadata: The input key
          - Result values: The input value associated to that key
          - Context context: The object where to store all the key-values generated (i.e., the map output) */

       public static class Mapper extends TableMapper<Text, Text> { 

         public void map(ImmutableBytesWritable rowMetadata, Result values, Context context) throws IOException, InterruptedException { 
           int i;
           int hash = context.getConfiguration().getInt("Hash", 0);
           
           String[] external = context.getConfiguration().getStrings("External", "Default");
           String[] internal = context.getConfiguration().getStrings("Internal", "Default");

		   // From the context object we obtain the input TableSplit this row belongs to
		   TableSplit currentSplit = (TableSplit)context.getInputSplit();
		   
		   /* 
			  From the TableSplit object, we can further extract the name of the table that the split belongs to.
			  We use the extracted table name to distinguish between external and internal tables as explained below. 
		   */
		   TableName tableNameB = currentSplit.getTable();				   
		   String tableName = tableNameB.getQualifierAsString();
		   
		   // We create a string as follows for each key: tableName#key;family:attributeValue
		   String tuple = tableName+"#"+new String(rowMetadata.get(), "US-ASCII");
           
           KeyValue[] attributes = values.raw();
           for (i=0;i<attributes.length;i++) {
             tuple = tuple+";"+new String(attributes[i].getFamily())+":"+new String(attributes[i].getQualifier())+":"+new String(attributes[i].getValue());
           }
           
           //Is this key external (e.g., from the external table)? 
           if (tableName.equalsIgnoreCase(external[0])) {
             //This writes a key-value pair to the context object
             //If it is external, it gets as key a hash value and it is written only once in the context object 
             context.write(new Text(Integer.toString(Double.valueOf(Math.random()*hash).intValue())), new Text(tuple));
           }
           //Is this key internal (e.g., from the internal table)?
           //If it is internal, it is written to the context object many times, each time having as key one of the potential hash values
           if (tableName.equalsIgnoreCase(internal[0])) {
             for(i=0;i<hash;i++) {
               context.write(new Text(Integer.toString(i)), new Text(tuple));
             }
           }
         } 
       } 

//================================================================== Reducer       
       public static class Reducer extends TableReducer<Text, Text, Text> { 

          /* The reduce is automatically called by the MapReduce framework after the Merge Sort step. 
          It receives a key, a list of values for that key, and a context object where to write the resulting key-value pairs. */

          public void reduce(Text key, Iterable<Text> inputList, Context context) throws IOException, InterruptedException { 
           int i,j,k;
           Put put;
           String eTableTuple, iTableTuple;
		   String eTuple, iTuple;
           String outputKey;
           String[] external = context.getConfiguration().getStrings("External","Default");
           String[] internal = context.getConfiguration().getStrings("Internal","Default");
           String[] eAttributes, iAttributes;
           String[] attribute_value;

           //All tuples with the same hash value are stored in a vector 
           Vector<String> tuples = new Vector<String>();
           for (Text val : inputList) {
             tuples.add(val.toString());
           }

           //In this for, each internal tuple is joined with each external tuple
           //Since the result must be stored in a HBase table, we configure a new Put, fill it with the joined data and write it in the context object 
           for (i=0;i<tuples.size();i++) {
             eTableTuple = tuples.get(i);	
			 // we extract the information from the tuple as we packed it in the mapper
			 eTuple=eTableTuple.split("#")[1];		 
             eAttributes=eTuple.split(";");
             if (eTableTuple.startsWith(external[0])) {
               for (j=0;j<tuples.size();j++) {			     
                 iTableTuple = tuples.get(j);			 
				 // we extract the information from the tuple as we packed it in the mapper
				 iTuple=iTableTuple.split("#")[1];	
                 iAttributes=iTuple.split(";");
                 if (iTableTuple.startsWith(internal[0])) {
                   // Create a key for the output
                   outputKey = eAttributes[0]+"_"+iAttributes[0];
                   // Create a tuple for the output table
                   put = new Put(outputKey.getBytes());
                   //Set the values for the columns of the external table
                   for (k=1;k<eAttributes.length;k++) {
                     attribute_value = eAttributes[k].split(":");
                     put.addColumn(attribute_value[0].getBytes(), attribute_value[1].getBytes(), attribute_value[2].getBytes());
                   }
                   //Set the values for the columns of the internal table
                   for (k=1;k<iAttributes.length;k++) {
                     attribute_value = iAttributes[k].split(":");
                     put.addColumn(attribute_value[0].getBytes(), attribute_value[1].getBytes(), attribute_value[2].getBytes());
                   }
                   // Put the tuple in the output table through the context object
                   context.write(new Text(outputKey), put); 
                 }
               }
             }
           }
         } 
       } 
    }


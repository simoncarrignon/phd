## document database

### XML & JSON
xml scema, json
JSON:need to know the queries
	* when schema is non fixed/evolving schema
	* distritubted data (easier than RDBMS) (relational data base management system)
 
MongoDB:the mysql of document database
find order with status 'A' => db.orders.find({status:"A"})

### Data model: graph database

problem with RDBMS: costly to extract realtion
so whhen it comes ot data graphs tructured: use graph database. Thas sounds logic . Neo4J:
table are inciidence
dificult to parralalelize


### Activity  database case:

will depend on the number of user vs number of order:

if lot of orders with lot of different products : 
	* Mongo DB


#### My try:

```json

user.jons:
{
	_id:uid,
	name: "BOB",
	dob: 12-21-21,
	address: {
			street:"rue de la paix",
			zip:213123,
			...
		
		}
	
	orders:["order_id1","order_id1","order_id1","order_id1","order_id1","order_id1"..]

	friends:[{"user_id":12-12-12},{"user_id":12-12-12},{"user_id":12-12-12},...]
}

order.json: 
{

	product: productid,
	date: 12-12-12,
	quantities:12,
	user:dasdas
}
 

```

queries:
	* most popular website

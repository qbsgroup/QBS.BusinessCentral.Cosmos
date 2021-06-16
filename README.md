# QBS.BC.Cosmos

One of the highest scoring FAQs from partners and customers moving to Business Central is about direct access to the SQL Server database in combination with the maximum database size.
When all you have is a hammer, everything looks like a nail. Since Dynamics NAV in the last ten years only ran on SQL Server this is what most partners know. Large customers often buy CPU licenses and since they have a SQL Server this is what they often start using as a Data Warehouse too.

The cloud equivalent of SQL Server is Azure SQL and this is fully supported by Business Central. In fact, this is what Microsoft uses for hosting the Saas platform.
One might be tempted to use Azure SQL then also for cloud data storage, but this may not always be the best choice. On Azure we have more than just a hammer.

Azure Cosmos Database is a good alternative in Azure if you are looking to store large amounts of data from different sources that you want to use in a Web Shop or other Web Based solution.
Question that rises is then, what would this cost, and how do I send information back and forth between Cosmos and Business Central.

The pricing model for Cosmos is different from Azure SQL in a sense that you pay for real throughput and storage. The storage model is cheaper than the model for Azure SQL.
Cosmos is also auto scale and auto indexed even though I expect that most of the workload from SMB customers will not be affected by this a lot.
# Cosmos vs. Azure Data Lake

In this article we discuss Cosmos as an alternative to Azure SQL. Cosmos is not the only alternative and in next articles we will also discuss Azure Data Lake and other blob based solutions.
Working with Cosmos & Business Central
As you may expect from my profile the main topic of this blog is the technology required to get data to move from Business Central to Cosmos. For this there are two options and I’ll describe both and share code examples.
In both cases we are going to use the Cosmos Rest API.

## The AL way
The first option, and probably the option of choice by experienced AL developers is to call the API directly from Business Central. This is a straight forward HTTP request where we send json information to a Cosmos container. The thing that may require to fiddle with a bit is the security tokens, but this has been laid out in the example code. You can find code examples on our GitHub.
## The C# way
Another option which will most likely be the preferred option by developers who are new to our community is to call the Business Central REST API from an Azure Function and push that data into Cosmos using some C# code. This is also part of the examples you can find on GitHub.
## Best of both worlds
Both options can also be combined. This depends how you want to schedule the synchronization. Scheduling can be done using a Logic App that synchronizes data every x minutes, or hours, or you can push the Azure Function from the Business Central Job Queue. Alternatively, you can even call the Azure Event Grid from a Business Central Webhook and use that to transform data from Business Central to Cosmos.
The Azure Function also allows data to be stored from other data sources such as a SOAP endpoint.

# Pitfalls and tips
You can store all kinds of data in Cosmos, based on containers just like Azure Blob Storage.
Cosmos is a No SQL database so it does not force you to follow schemas.
The consequence of the lack of schema’s is that it becomes the responsibility of the owner of the database to make sure data in a container is consistent and all json files follow the same structure.

As an example, let’s assume you have created a container with Item Inventory by date and you want to add location code as a new field. You need to update old records with the location code or create a new container with fresh data.
The example code provided on the GitHub contains a Version No. field and some extra Metadata about the json stored in the container. This allows you to have multiple versions of a record in the same container and store, for example, items and resources in the same container. This can have an advantage if you need an aggregation across Business Central entities in one container.
Because throughput is the main driver for cost in Cosmos it can also be beneficial to duplicate data across containers if there is a clear difference in data requirements across certain BI dashboards. For example, certain dashboards only require a customer name, where other dashboards require post codes or city.
Since data is stored in json format you can store parent and child information in one container, such as Sales Headers and Lines.

# Creating a new Cosmos Instance & Database
One of the reasons Cosmos can be interesting for the SMB market and Business Central users is that it provides a free entry level of 25GB and 1000ru. This should suffice for an average 
database combining data from Business Central and other entities.
 
## API
You can choose any API you are familiar with, but the examples on our GitHub are based on Core SQL. This syntax is relatively close to Transact SQL that most Business Central power users are familiar with.
 
## Serverless or Provisioned

Probably serverless since we are having very incremental workloads. If we don’t use Cosmos, we only pay for storage.
## Account Name
The account name is a generic name, used for all databases, just like an Azure SQL Server.
Other options may be left default or may vary based on your organizational backup and security policies and are not part of the scope of this document.
## Creating a Database and a Container
In our code examples the Database and Container are created by the Azure Function in C# if you try to write to a Database and/or Container that does not exist. The AL code does not contain examples of creating a Database or Container automatically. If you go for AL only you need to either write this code or create them manually via the Azure Portal.
 






 select
    sh.OrderDate, sh.SalesOrderID,sh.SubTotal,
    sd.OrderQty, sd.ProductID, sd.UnitPriceDiscount, sd.LineTotal,
    pp.ListPrice, pp.StandardCost, pp.[Name] as product_name,
    psb.[name] as sub_category,
    pc.[Name] as category,
	pp.Color, pp.Size, pp.[Weight], pp.Class, pp.Style,
	sh.CustomerID
 into mainTable
 from Sales.SalesOrderDetail sd
 join Sales.SalesOrderHeader sh
    on sd.SalesOrderID = sh.SalesOrderID
 join Production.Product pp
    on sd.ProductID = pp.ProductID
 left join Production.ProductSubcategory psb
    on pp.ProductSubcategoryID = psb.ProductSubcategoryID
 left join Production.ProductCategory pc
    on psb.ProductCategoryID = pc.ProductCategoryID


--########### how many product does company  ? ###########
select 
    COUNT (ProductID) as number_of_product
from Production.Product


--########### how many product have been sold ? ###########
select 
    COUNT(distinct ProductID) as total_qty_sold
from mainTable;

------#########what is the total revenue#######---------------
select  
	SUM(LineTotal) as revenue
from mainTable

------#########what is the total profit#######---------------
select 
    sum(LineTotal - (StandardCost * OrderQty)) as profit
from mainTable


--########### What is the total order qty ? ###########
select
    sum(OrderQty) as total_qty
from mainTable;

--########### What is the total number of sales ? ###########
select 
    COUNT(distinct SalesOrderID) as total_num_sold
from mainTable;

--########### What is the total line order ? ###########
select
    COUNT(*) as total_num_line
from mainTable;

---------!!!!!!!!!!!! Q1 Is the revenue/profitability seasonal? !!!!!!!!!!!!----------------------	

--########### What is the total revenue/profit per month? ###########
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
    sum(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(orderqty) as 'Order Qty',
	count(*) as 'Number of order',
    rank() over (order by YEAR(OrderDate), MONTH(OrderDate)) as month_rank
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)
order by YEAR(OrderDate), MONTH(OrderDate);

-----------------------the ranking of revenue monthly------------------------------------------------------
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
    rank() over (order by SUM(LineTotal) desc) as month_rank
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)

-----------------------the ranking of profit monthly------------------------------------------------------
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
	sum(LineTotal - (StandardCost * OrderQty)) as profit,
    rank() over (order by sum(LineTotal - (StandardCost * OrderQty))desc) as month_rank
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)


-----------------------the ranking of Order Qty monthly------------------------------------------------------
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
	SUM(orderqty) as 'Order Qty',
    rank() over (order by SUM(orderqty) desc) as month_rank
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)

-----------------------the ranking of the number of order monthly------------------------------------------------------
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
	count(*) as 'Number of order',
    rank() over (order by count(*) desc) as month_rank
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)




--########### What is the average of the discounts on a single item? ###########
select
    AVG(UnitPriceDiscount) as average_discount
from mainTable
where UnitPriceDiscount is not null;
-------------------------------------------------------------------------
select
    AVG(UnitPriceDiscount) as average_discount
from mainTable
where 
    UnitPriceDiscount is not null 
    and UnitPriceDiscount != 0;
-------------------------------------------------------------------------
select
    ProductID,
    AVG(UnitPriceDiscount) as average_discount
from mainTable
where UnitPriceDiscount is not null
group by ProductID
order by ProductID

----------------------monthly discount ----------------------------------------

select YEAR(orderdate) 'year of order' , MONTH(orderdate) 'month of order' ,
    AVG(UnitPriceDiscount) as average_discount,
	rank() over (order by AVG(UnitPriceDiscount) desc) as month_rank
from mainTable
group by YEAR(orderdate), MONTH(orderdate)

----------------------monthly discount execpt unit discount = 0-----------------------------------------

select YEAR(orderdate) 'year of order' , MONTH(orderdate) 'month of order' ,
    AVG(UnitPriceDiscount) as average_discount,
	rank() over (order by AVG(UnitPriceDiscount) desc) as month_rank
from mainTable
where UnitPriceDiscount <> 0
group by YEAR(orderdate), MONTH(orderdate)


------------########### Min, Max, Avg of Unitprcie discount per Discount type ##################------------------------- 
select 
	t2.SpecialOfferID, 
	t2.[Type],
	min(t1.UnitPriceDiscount) Min_Discount,
	max(t1.UnitPriceDiscount) Max_Discount,  
	avg(t1.UnitPriceDiscount) Avg_Discount
from Sales.SalesOrderDetail t1
	join Sales.SpecialOffer t2
		on t1.SpecialOfferID = t2.SpecialOfferID
group by t2.SpecialOfferID, t2.[Type]
order by t2.SpecialOfferID

--########### Discount Patterns ###########
select 
	DAY(OrderDate) as [day],
	count(*) as num_of_discount
from mainTable
where UnitPriceDiscount != 0
group by DAY(OrderDate)
order by num_of_discount desc;




---------!!!!!!! Q2 Is there an upward or downward trend in the company's data over the months and years? !!!!!!---------------
--------------------------Discount Table-------------------------------------------
select  
	t1.OrderDate,year(t1.OrderDate) orderyear, month(t1.OrderDate) ordermonth, t1.CustomerID, 
	t2.orderqty, t4.SpecialOfferID, t2.LineTotal, 
	t2.ProductID, t2.UnitPrice, t2.UnitPriceDiscount,
	t3.[Name] ProductName, t3.StandardCost,
	t4.[Type], t4.[Description], t4.DiscountPct,
	t5.PersonID, t5.StoreID

from Sales.SalesOrderHeader t1
	join sales.SalesOrderDetail t2
		on t1.SalesOrderID =t2.SalesOrderID
	join Production.Product t3
		on t2.ProductID =t3.ProductID
	join Sales.SpecialOffer t4
		on t4.SpecialOfferID = t2.SpecialOfferID
	join Sales.Customer t5
		on t5.CustomerID = t1.CustomerID

------------------------monthly discount type-------------------------------------------------------------
select  orderyear, ordermonth, 
SpecialOfferID, [Type],
sum(orderqty) Oder_Qty, count(*) numberoforder,
sum(LineTotal-(StandardCost*OrderQty)) profit
from Discount_Table
group by orderyear, ordermonth, 
[Type], SpecialOfferID
order by  orderyear, ordermonth,[Type], SpecialOfferID 

------------------------------Excess inventory ------------------------------
select distinct  orderyear,  ordermonth,
ProductID, productName, sum(Orderqty) 'Number Of Order',
SpecialOfferID, [Type]
from Discount_table
where [Type] ='Excess Inventory'
group by orderyear,  ordermonth,
ProductID, productName,SpecialOfferID, [Type]

------------------------Discontinued Product --------------------------------
select distinct orderyear, ordermonth,
ProductID, productName,
SpecialOfferID, [Type]
from Discount_Table
where [Type] ='Discontinued Product'
order by  orderyear, ordermonth, ProductID


----------------Store Discount type and Min, Max-------------------------
select SpecialOfferID, [Type], [Description] ,DiscountPct, 
max(UnitPriceDiscount),
min(UnitpriceDiscount),
AVG(UnitpriceDiscount)
from Discount_Table
where StoreID is not null
and personID is not null
group by SpecialOfferID, [Type],DiscountPct, [Description]
order by SpecialOfferID



----------------person Discount type and Min, Max-------------------------
select SpecialOfferID, [Type], [Description] ,DiscountPct, 
max(UnitPriceDiscount),
min(UnitpriceDiscount),
AVG(UnitpriceDiscount)
from Discount_Table
where StoreID is null
and personID is not null
group by SpecialOfferID, [Type],DiscountPct, [Description]
order by SpecialOfferID




---------!!!!! Q3.Choose one topic that affects the company's profitability, study it and give recommendations based on data for how to improve the company's profitability.!!!!!!------------

----------------------#City Table#----------------------------------
SELECT 
	Sales.SalesOrderHeader.SalesOrderID, 
	Sales.Customer.PersonID, Sales.Customer.StoreID, Sales.Customer.CustomerID,
	Person.[Address].City, 
	Person.StateProvince.StateProvinceCode,Person.StateProvince.[Name], 
	Person.CountryRegion.CountryRegionCode,Person.CountryRegion.[Name] AS Country, 
	Sales.SalesOrderDetail.OrderQty, Sales.SalesOrderDetail.UnitPrice, 
	Sales.SalesOrderDetail.UnitPriceDiscount, Sales.SalesOrderDetail.LineTotal, 
	Production.Product.StandardCost, Production.Product.ProductID, 
	Production.ProductCategory.[Name] AS Category,	
	Production.ProductSubcategory.[Name] AS Subcategory,
	Sales.SpecialOffer.SpecialOfferID, Sales.SpecialOffer.[Description], 
	Sales.SpecialOffer.DiscountPct, Sales.SpecialOffer.[Type]
into city_category
FROM Person.[Address] 
left JOIN Sales.SalesOrderHeader 
				ON Person.[Address].AddressID = Sales.SalesOrderHeader.ShipToAddressID 
			INNER JOIN Sales.Customer 
				ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID 
			INNER JOIn Person.StateProvince 
				ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID 
			INNER JOIN Person.CountryRegion 
				 ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode 
			INNER JOIN  Sales.SalesOrderDetail 
				 ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID 
			INNER JOIN Production.Product 
				 ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID 
			INNER JOIN Production.ProductSubcategory 
				 ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
			INNER JOIN  Production.ProductCategory 
				 ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID 
			INNER JOIN Sales.SpecialOffer 
				ON Sales.SalesOrderDetail.SpecialOfferID = Sales.SpecialOffer.SpecialOfferID

------------#total number of order, orderqty, profit from store customer-------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty, count(*) numberofsales
from city_category
where PersonID is not null
and storeID is not null
------------#total number of order, orderqty, profit from personal customer-------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty, count(*) numberofsales
from city_category
where PersonID is not null
and storeID is null
------------#total number of order, orderqty, profit from store customer for discounted product-------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty, count(*) numberofsales
from city_category
where PersonID is not null
and storeID is not null
and SpecialOfferID <> 1
------------#total number of order, orderqty, profit from personal customer for discounted product-------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty, count(*) numberofsales
from city_category
where PersonID is not null
and storeID is null
and SpecialOfferID<>1

---------------total Profit and OrderQty--------------------------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category

---------------Total profit by country-------------------------------------
select Country, sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
group by  Country
order by sum(linetotal - (orderqty*standardcost)) desc

---------------Total profit by city-------------------------------------
select [Name], City, sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
group by  [Name], City
order by sum(linetotal - (orderqty*standardcost)) desc


----------------store total profit-----------------------------------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where StoreID is not null

----------------Personal total profit--------------------------------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where PersonID is not null
and storeID is null


----------------store profit by city-----------------------------------------
select Country, [Name], City, sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where StoreID is not null
group by  Country, [Name], City
order by sum(linetotal - (orderqty*standardcost)) desc

----------------Personal total profit--------------------------------------
select  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where PersonID is not null
and storeID is null


----------------Personal total profit by city---------------------------------------
select Country, [Name], City, sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where personid is not null AND storeID is null
group by  Country, [Name], City
order by sum(linetotal - (orderqty*standardcost)) desc



---------------Total profit by country-------------------------------------
select Country, sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
group by  Country
order by sum(linetotal - (orderqty*standardcost)) desc

----------------Store OrderQty by city and Subcategory-----------------------------------------
select City, Subcategory,  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where StoreID is not null
and city in ('Seattle', 'edmonton', 'Toronto', 'Memphis')
group by  Subcategory, City
order by City,sum(orderqty) desc



----------------Personal OrderQty by city and Subcategory-----------------------------------------
select City, Subcategory,  sum(linetotal - (orderqty*standardcost)) Profit,
sum(orderqty) OrderQty
from city_category
where PersonID is not null
and storeID is null
and city in ('london', 'Paris', 'byron', 'chehalis')
group by  Subcategory, City
order by City, sum(orderqty) desc

-----------------------Toronto discount-----------------------
select SpecialOfferID, [type], [Description], sum(OrderQty) orderqty,
DiscountPct,
min(UnitPriceDiscount) MinDiscount,
Max(UnitPriceDiscount) MaxDiscount,
sum(linetotal-(orderqty*standardcost)) profit
from city_category
where PersonID is not null
and StoreID is not null
and City = 'toronto'
group by SpecialOfferID, [Description], [type], DiscountPct
order by SpecialOfferID

-----------------------Seattle discount-----------------------
select SpecialOfferID, [type], [Description], sum(OrderQty) orderqty,
DiscountPct,
min(UnitPriceDiscount) MinDiscount,
Max(UnitPriceDiscount) MaxDiscount,
sum(linetotal-(orderqty*standardcost)) profit
from city_category
where PersonID is not null
and StoreID is not null
and City = 'Seattle'
group by SpecialOfferID, [Description], [type], DiscountPct
order by SpecialOfferID


------------Personal customer unitprice-standardcost----------------
------step1
select customerid,personid, storeid, orderqty,
(unitprice-standardcost)'unitprice-standardcost'
from city_category
where personID is not null
and storeid is null
order by customerid

------step2
select personid, 
count(*) numberofsalesorder,
sum(unitprice-standardcost)'unitprice-standardcost'
from city_category
where personID is not null
and storeid is null
group by  personid
order by  count(*) desc, sum(unitprice-standardcost)

------step3
select max(t2.numberofsalesorder) maxsalesorder,
AVG(t2.numberofsalesorder) avgsalesorder,
min(t2.numberofsalesorder) minsalesorder,
MAX(t2.[unitprice-standardcost]) 'Max(uni-stan)',
Avg(t2.[unitprice-standardcost]) 'Avg(uni-stan)',
min(t2.[unitprice-standardcost]) 'Min(uni-stan)',
sum(t2.[unitprice-standardcost]) 'sum(uni-stan)'
from city_category t1
join (select customerid,
	count(*) numberofsalesorder,
	sum(unitprice-standardcost)'unitprice-standardcost'
	from city_category
	where personID is not null
	and storeid is null
	group by  customerid,personid, storeid) as t2
	on t1.customerID = t2.customerID

-----------Store customer unitprice-standardcost-----------------
------step1
select customerid,personid, storeid, orderqty,
(unitprice-standardcost)'unitprice-standardcost'
from city_category
where personID is not null
and storeid is not null
order by customerid

------step2
select personid, 
count(*) numberofsalesorder,
sum(unitprice-standardcost)'unitprice-standardcost'
from city_category
where personID is not null
and storeid is not null
group by  personid
order by  count(*) desc, sum(unitprice-standardcost)

------step3
select max(t2.numberofsalesorder) maxsalesorder,
AVG(t2.numberofsalesorder) avgsalesorder,
min(t2.numberofsalesorder) minsalesorder,
MAX(t2.[unitprice-standardcost]) 'Max(uni-stan)',
Avg(t2.[unitprice-standardcost]) 'Avg(uni-stan)',
min(t2.[unitprice-standardcost]) 'Min(uni-stan)',
sum(t2.[unitprice-standardcost]) 'sum(uni-stan)'
from city_category t1
join (select customerid,
	count(*) numberofsalesorder,
	sum(unitprice-standardcost)'unitprice-standardcost'
	from city_category
	where personID is not null
	and storeid is not null
	group by  customerid,personid, storeid) as t2
	on t1.customerID = t2.customerID


--------##############Product (revenue, profit, qty)################----------------------
select　
	productID, 
	product_name,
    sub_category,
    category,
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	RANK() OVER (ORDER BY sum(orderqty)desc ) AS Rank_Qty,
	sum(LineTotal - (OrderQty * StandardCost)) profit,
	RANK() OVER (ORDER BY sum(LineTotal - (OrderQty * StandardCost))desc ) AS Rank_profit
from mainTable
group by productID, 
	product_name,
    sub_category,
    category
order by sum(orderqty) desc

-------########### Category types (revenue, profit, qty)-########### --------------;
-------------------------Category, Subcategory montly---------------------------------------
select　
	category,
    sub_category,
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	sum(LineTotal - (OrderQty * StandardCost)) profit
from  mainTable
group by 
		 category,sub_category, 
		 YEAR(OrderDate),
		MONTH(OrderDate)
order by sum(LineTotal - (OrderQty * StandardCost))

---------------------------Category, Subcategory---------------------------------------------
select　
	category,
    sub_category,
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	sum(LineTotal - (OrderQty * StandardCost)) profit,
	sum(LineTotal - (OrderQty * StandardCost)) /sum(orderqty) 'Profit per product'
from  mainTable
group by category,sub_category
order by sum(LineTotal - (OrderQty * StandardCost)) /sum(orderqty)  desc
		
-------------------------Category montly---------------------------------------
select　
	category,
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	sum(LineTotal - (OrderQty * StandardCost)) profit
from  mainTable
group by 
		 category,
		 YEAR(OrderDate),
		MONTH(OrderDate)
order by category ,
		 YEAR(OrderDate),
		MONTH(OrderDate)

---------------------------Category---------------------------------------------
select　
	category,
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	sum(LineTotal - (OrderQty * StandardCost)) profit,
	RANK() OVER (ORDER BY sum(orderqty)desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY sum(LineTotal - (OrderQty * StandardCost))desc ) AS Rank_profit
from  mainTable
group by category
order by sum(orderqty) desc

------------------number of product per category-----------------------------
select t3.[Name],t2.[name], COUNT(t1.productID) 'Number of category'
from Production.Product t1
	join Production.ProductSubcategory t2
		on t1.ProductSubcategoryID =t2.ProductSubcategoryID
	join Production.ProductCategory t3
		on t2.ProductCategoryID = t3.ProductCategoryID
	group by t2.[name], t3.[Name]

--########### Color, Size, Weight, Class and Style Patterns ###########
-------------------------color montly---------------------------------------

select
	Color,
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by Color, YEAR(OrderDate), MONTH(OrderDate)
order by Color, [year], [month];
-------------------------color---------------------------------------
select
	Color, sub_category,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by Color, sub_category
order by SUM(OrderQty) desc
-------------------------Size montly--------------------------------------
select
	Size, 
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by Size, YEAR(OrderDate), MONTH(OrderDate)
order by Size, [year], [month];
-------------------------Size---------------------------------------
select
	Size,sub_category,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Size, sub_category
order by SUM(OrderQty) desc

-------------------------weight montly-------------------------------------
select
	[Weight],
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by [Weight], YEAR(OrderDate), MONTH(OrderDate)
order by [Weight], [year], [month];
-------------------------weight -------------------------------------
select
	[Weight],sub_category,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by [Weight],sub_category
order by SUM(OrderQty) desc

-------------------------Class montly-------------------------------------
select
	Class,
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by Class, YEAR(OrderDate), MONTH(OrderDate)
order by Class, [year], [month];
------------------------Class -------------------------------------
select
	Class,sub_category,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Class, sub_category
order by SUM(OrderQty) desc


-------------------------Style montly-------------------------------------
select
	Style,
	YEAR(OrderDate) as [year],
	MONTH(OrderDate) as [month],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by Style, YEAR(OrderDate), MONTH(OrderDate)
order by Style, [year], [month]

------------------------Style -------------------------------------
select
	Style,sub_category,category,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Style, sub_category,category
order by category


-------------------------------------------total
select
	category, sub_category,Style, color, class, [weight], size, 
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty
from mainTable
group by category, sub_category,Style, color, class, [weight], size
order by category



--########### Products: more qty, more revenue, more profit. ###########
select
    ProductID,
    product_name,
    COUNT(OrderQty) as total_qty_sold
from mainTable
group by ProductID, product_name
order by total_qty_sold desc;

-------------------------------------------------------------------------
select
    ProductID,
    product_name,
    SUM(LineTotal) as total_revenue
from mainTable
group by ProductID, product_name
order by total_revenue desc;
-------------------------------------------------------------------------
select
    ProductID,
    product_name,
    SUM((ListPrice - StandardCost) * OrderQty) as total_profit
from mainTable
group by ProductID, product_name
order by total_profit desc;

--########### How much is the margin ? ###########
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
    avg(ListPrice / StandardCost)*100 as margin,
	rank() over(order by  avg(ListPrice / StandardCost)*100 desc) as RanK_marigin
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate);

--########### What is the average margin? ###########
select
    YEAR(OrderDate) as [year],
    MONTH(OrderDate) as [month],
    AVG(ListPrice / StandardCost)*100 as margin_avg
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate)
order by YEAR(OrderDate), MONTH(OrderDate);

--########### What is the average and total of profit/revenue per category and subcategory? ###########
select
    sub_category,
    category,
    AVG(UnitPriceDiscount) as avg_discount,
    SUM(LineTotal - (StandardCost * OrderQty)) as total_profit,
    AVG(LineTotal - (StandardCost * OrderQty)) as avg_profit,
    SUM(LineTotal) as total_revenue,
    AVG(LineTotal) as avg_order_revenue,
	AVG(ListPrice / StandardCost) as margin_avg
from mainTable
group by category, sub_category;



---------#########Products frequently bought together#########----------
select 
	t1.ProductID as Product1,
		(select p.Name
		 from Production.Product p
			join Production.ProductSubcategory psc
				on p.ProductSubcategoryID = psc.ProductSubcategoryID
			join production.ProductCategory pc
				on psc.productcategoryid = pc.productcategoryid
		 where p.ProductID = t1.ProductID
		) as Product1Name,
	t2.ProductID as Product2,
		(select p.Name
		 from Production.Product p
			join Production.ProductSubcategory psc
				on p.ProductSubcategoryID = psc.ProductSubcategoryID
			join production.ProductCategory pc
				on psc.productcategoryid = pc.productcategoryid
		 where p.ProductID = t2.ProductID
		) as Product2Name,
	count(t1.SalesOrderID) as HowOften
from 
	Sales.SalesOrderDetail t1
	join Sales.SalesOrderDetail t2
		on t1.SalesOrderID = t2.SalesOrderID and 
			t1.ProductID < t2.ProductID
group by t1.ProductID,t2.ProductID
order by HowOften desc

--------######Number of new Customer###########--------------------
select
	YEAR(FirstDate) as [Year],
	Month(FirstDate) as [Month],
	COUNT(customerid) as NoOfNewCustomer,
	Rank() over (order by COUNT(customerid) desc) as 'Rank'
from
	(select 
		CustomerID, MIN(orderdate)as FirstDate
	from 
		sales.SalesOrderHeader
	group by CustomerID) as tbl
group by YEAR(FirstDate), Month(FirstDate)

--############# 
select
	OrderDate,
	SalesOrderID,
	CustomerID,
	productID,
	product_name,
	OrderQty,
	category,
	sub_category,
	LineTotal
from mainTable
where SalesOrderID in (select
							min(SalesOrderID)
						from mainTable
						group by CustomerID);

------------------------------------------------first customer count order qty 
select category, sub_category, count(*) numberoffirstorder
from firstOrders
group by category,sub_category
order by count(*) desc



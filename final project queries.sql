select
    sh.OrderDate,
    sh.SalesOrderID,
    sh.SubTotal,
    sd.OrderQty,
    sd.ProductID,
    sd.UnitPriceDiscount,
    sd.LineTotal,
    pp.ListPrice,
    pp.StandardCost, 
    pp.[Name] as product_name,
    psb.[name] as sub_category,
    pc.[Name] as category,
	pp.Color,
	pp.Size,
	pp.[Weight],
	pp.Class,
	pp.Style

into mainTable
from Sales.SalesOrderDetail sd
join Sales.SalesOrderHeader sh
    on sd.SalesOrderID = sh.SalesOrderID
join Production.Product pp
    on sd.ProductID = pp.ProductID
left join Production.ProductSubcategory psb
    on pp.ProductSubcategoryID = psb.ProductSubcategoryID
left join Production.ProductCategory pc
    on psb.ProductCategoryID = pc.ProductCategoryID;

--########### What is the total order qty ? ###########
select
    sum(OrderQty) as total_qty
from mainTable;

--########### What is the total line order ? ###########
select
    COUNT(*) as total_num_line
from mainTable;


--########### What is the total number of sales ? ###########
select 
    COUNT(distinct SalesOrderID) as total_num_sold
from mainTable;

--########### how many product does company  ? ###########
select 
    COUNT (ProductID) as number_of_product
from Production.Product


--########### how many product have been sold ? ###########
select 
    COUNT(distinct ProductID) as total_qty_sold
from mainTable;

---------!!!!!!!!!!!! Q1 Is the revenue/profitability seasonal? !!!!!!!!!!!!----------------------	
--########### What is the total revenue/profit? ###########
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




---------!!!!!!! Q2 Is there an upward or downward trend in the company's data over the months and years? !!!!!!-----------------

------------------------monthly discount type-------------------------------------------------------------
select  year(t1.OrderDate) orderyear, month(t1.OrderDate) ordermonth, t4.SpecialOfferID, t4.[Type],
sum(t2.orderqty) Oder_Qty, count(*) numberoforder,
sum(t2.LineTotal-(t3.StandardCost*t2.OrderQty)) profit
from Sales.SalesOrderHeader t1
join sales.SalesOrderDetail t2
on t1.SalesOrderID =t2.SalesOrderID
join Production.Product t3
on t2.ProductID =t3.ProductID
join Sales.SpecialOffer t4
on t4.SpecialOfferID = t2.SpecialOfferID
group by year(t1.OrderDate), month(t1.OrderDate),t4.[Type], t4.SpecialOfferID
order by  year(t1.OrderDate), month(t1.OrderDate), t4.SpecialOfferID

------------------------------Excess inventory - Product ID 762--------------------------------
select distinct year(t1.OrderDate) orderyear, month(t1.OrderDate) ordermonth,
t2.ProductID, t3.[Name],
t4.SpecialOfferID, t4.[Type]
from Sales.SalesOrderHeader t1
join sales.SalesOrderDetail t2
on t1.SalesOrderID =t2.SalesOrderID
join Production.Product t3
on t2.ProductID =t3.ProductID
join Sales.SpecialOffer t4
on t4.SpecialOfferID = t2.SpecialOfferID
where t4.[Type] ='Excess Inventory'
order by  year(t1.OrderDate), month(t1.OrderDate), t2.ProductID

------------------------Discontinued Product --------------------------------
select distinct  year(t1.OrderDate) orderyear, month(t1.OrderDate) ordermonth,
t2.ProductID, t3.[Name],
t4.SpecialOfferID, t4.[Type]
from Sales.SalesOrderHeader t1
join sales.SalesOrderDetail t2
on t1.SalesOrderID =t2.SalesOrderID
join Production.Product t3
on t2.ProductID =t3.ProductID
join Sales.SpecialOffer t4
on t4.SpecialOfferID = t2.SpecialOfferID
where t4.[Type] ='Discontinued Product'
order by  year(t1.OrderDate), month(t1.OrderDate), t2.ProductID


---------!!!!! Q3.Choose one topic that affects the company's profitability, study it and give recommendations based on data for how to improve the company's profitability.!!!!!!------------
----------------###########City per customer (expand the market)###########---------------basic table 

select t6.City, t7.[Name],
sum(t2.LineTotal-(t2.OrderQty*t8.StandardCost)) as profit,
sum(t2.orderqty) as orderQty
from Sales.SalesOrderHeader t1
join Sales.SalesOrderDetail t2
on t1.SalesOrderID = t2.SalesOrderID
join Sales.Customer t3
	on t1.CustomerID = t3.CustomerID
join Person.Person t4
	on t3.PersonID = t4.BusinessEntityID
join Person.BusinessEntityAddress t5
	on t4.BusinessEntityID = t5.BusinessEntityID
join person.[Address] t6
	on t5.AddressID =t6.AddressID
join person.StateProvince t7
	on t6.StateProvinceID = t7.StateProvinceID
join Production.Product t8
	on t2.ProductID =t8.ProductID
group by t6.City, t7.[name]
order by sum(t2.orderqty) desc


--------------------city per store------------------------------


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
order by ProductID

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
order by category, sub_category, 
		 YEAR(OrderDate),
		MONTH(OrderDate)

---------------------------Category, Subcategory---------------------------------------------
select　
	category,
    sub_category,
	sum(linetotal) revenue,
	sum(orderqty) orderaty,
	sum(LineTotal - (OrderQty * StandardCost)) profit,
	RANK() OVER (ORDER BY sum(orderqty)desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY sum(LineTotal - (OrderQty * StandardCost))desc ) AS Rank_profit
from  mainTable
group by category,sub_category
order by sum(orderqty) desc
		
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
	Color,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Color
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
	Size,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Size
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
	[Weight],
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by [Weight]
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
	Class,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Class
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
	Style,
	SUM(LineTotal) as revenue,
	SUM(LineTotal - (StandardCost * OrderQty)) as profit,
	SUM(OrderQty) as qty,
	RANK() OVER (ORDER BY SUM(OrderQty) desc ) AS Rank_Qty,
	RANK() OVER (ORDER BY SUM(LineTotal - (StandardCost * OrderQty)) desc ) AS Rank_profit
from mainTable
group by Style
order by SUM(OrderQty) desc






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
    SUM(ListPrice / StandardCost) as margin,
	rank() over(order by  SUM(ListPrice / StandardCost) desc) as RanK_marigin
from mainTable
group by YEAR(OrderDate), MONTH(OrderDate);

--########### What is the average margin (sale price less cost)? ###########
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

# SQL FINAL PROJECT
## :black_nib: About

This is the documentation for the final project of SQL class from Greystone College!

## :heavy_check_mark: Requirements

To your Dashboard works you have to download AdventureWorks2016 database and to use the databas with your Power Bi.

On your SQL:

```SQL
select
  sh.OrderDate,
  sh.SalesOrderID,
  sh.SubTotal,
  sd.OrderQty,
  sd.ProductID,
  sd.UnitPriceDiscount,
  so.[Type],
  sd.LineTotal,
  pp.ListPrice,
  pp.StandardCost,
  sd.LineTotal - (pp.StandardCost * sd.OrderQty) as profit, 
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
    on psb.ProductCategoryID = pc.ProductCategoryID
join Sales.SpecialOffer so
	on sd.SpecialOfferID = so.SpecialOfferID;

```

On your Power Bi:

```SQL
select * from mainTable
```

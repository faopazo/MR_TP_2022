--Exploración de la base y el negocio

--Oficinas de venta
SELECT DISTINCT [Group]
FROM Sales.SalesTerritory;

--Canales de venta
SELECT DISTINCT OnlineOrderFlag
FROM Sales.SalesOrderHeader;

--Categorías de productos
SELECT *
FROM Production.ProductCategory

--Tipos de bicicletas
SELECT *
FROM Production.ProductSubcategory
WHERE ProductCategoryID=1;

--Categoría de producto más vendido (Accesorios_botella):
SELECT c.ProductCategoryID, c.Name
FROM Sales.SalesOrderDetail d INNER JOIN Production.Product p ON d.ProductID=p.ProductID
INNER JOIN Production.ProductSubcategory s ON p.ProductSubcategoryID=s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON s.ProductCategoryID=c.ProductCategoryID
GROUP BY c.ProductCategoryID, c.Name
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM Sales.SalesOrderDetail d1 INNER JOIN Production.Product p1 ON d1.ProductID=p1.ProductID
                        INNER JOIN Production.ProductSubcategory s1 ON p1.ProductSubcategoryID=s1.ProductSubcategoryID
                        INNER JOIN Production.ProductCategory c1 ON s1.ProductCategoryID=c1.ProductCategoryID
                        GROUP BY c1.ProductCategoryID);

--Productos más vendidos y sus categorías / subcategorías
SELECT d.ProductID, p.Name AS Nombre_producto, s.Name AS Nombre_subcategoria, c.Name AS Nombre_categoria, COUNT(*) Cantidad_vendida
FROM Sales.SalesOrderDetail d INNER JOIN Production.Product p ON d.ProductID=p.ProductID
INNER JOIN Production.ProductSubcategory s ON p.ProductSubcategoryID=s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON s.ProductCategoryID=c.ProductCategoryID
GROUP BY d.ProductID, p.Name, s.Name, c.Name
ORDER BY Cantidad_vendida DESC;

--Cantidad de ventas agrupado por subcategorías y categorías (Road Bikes)
SELECT s.Name AS Nombre_subcategoria, c.Name AS Nombre_categoria, COUNT(*) Cantidad_vendida
FROM Sales.SalesOrderDetail d INNER JOIN Production.Product p ON d.ProductID=p.ProductID
INNER JOIN Production.ProductSubcategory s ON p.ProductSubcategoryID=s.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON s.ProductCategoryID=c.ProductCategoryID
GROUP BY s.Name, c.Name
ORDER BY Cantidad_vendida DESC;




--Ventas online vs. por resellers
--(Análisis exploratorio comparativo inicial)

--Total órdenes 31465:
SELECT COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader;
 
--Total órdenes online 27659:
SELECT COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL;

--Total órdenes resellers 3806:
SELECT COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL;

--Cantidad órdenes por tipo compra:
SELECT 'física' AS tipo_compra, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY OnlineOrderFlag
UNION 
SELECT 'online' AS tipo_compra, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
GROUP BY OnlineOrderFlag
ORDER BY 2 DESC;
 
--Monto total por tipo compra:
SELECT 'física' AS tipo_compra, FORMAT(SUM(TotalDue),'C') Monto_total
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY OnlineOrderFlag
UNION 
SELECT 'online' AS tipo_compra, FORMAT(SUM(TotalDue),'C') Monto_total
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
GROUP BY OnlineOrderFlag
ORDER BY 2 DESC;


--Hay mayor cantidad de compras online, sin embargo el mayor monto total es de compras físicas.


--Cantidad de órdenes físicas por año 
SELECT YEAR(OrderDate) Año, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY YEAR(OrderDate)
ORDER BY Año;

--Cantidad de órdenes online por año
 
SELECT YEAR(OrderDate) Año, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL
GROUP BY YEAR(OrderDate)
ORDER BY Año;
 
--Cantidad de órdenes por año y tipo de compra
SELECT YEAR(OrderDate) Año, 'física' as Tipo_compra, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY YEAR(OrderDate)
UNION
SELECT  YEAR(OrderDate) Año, 'online' as Tipo_compra, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL
GROUP BY YEAR(OrderDate)
ORDER BY 1 DESC, 3 DESC;

 
--TOP 10 ventas online por año y mes
SELECT TOP 10 YEAR(OrderDate) Año, MONTH(OrderDate) Mes, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL
GROUP BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) 
ORDER BY Cantidad_ordenes DESC; 
 
--EDA LineTotal
SELECT 'resellers' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal) as rango,
avg(LineTotal) as media,
stdev(LineTotal) as desviacion_estandard,
exp(avg(log(LineTotal))) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
WHERE OnlineOrderFlag = 0
UNION
SELECT 'ventas_online' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal) as rango,
avg(LineTotal) as media,
stdev(LineTotal) as desviacion_estandard,
exp(avg(log(LineTotal))) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
WHERE OnlineOrderFlag = 1;

-- EDA TotalDue
SELECT 'resellers' as Tipo_compra, count(TotalDue) as cantidad,
count(distinct TotalDue) as cardinalidad,
max(TotalDue) - min(TotalDue) as rango,
avg(TotalDue) as media,
stdev(TotalDue) as desviacion_estandard,
exp(avg(log(TotalDue))) as media_geometrica,
count(TotalDue) / Sum(1/TotalDue) as media_armonica
FROM Sales.SalesOrderHeader 
WHERE OnlineOrderFlag = 0
UNION
SELECT 'ventas_online' as Tipo_compra, count(TotalDue) as cantidad,
count(distinct TotalDue) as cardinalidad,
max(TotalDue) - min(TotalDue) as rango,
avg(TotalDue) as media,
stdev(TotalDue) as desviacion_estandard,
exp(avg(log(TotalDue))) as media_geometrica,
count(TotalDue) / Sum(1/TotalDue) as media_armonica
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1;
 

--Cantidad y montos de compras (online/fisica) por zonas
SELECT t.Name as Zona, t.[Group] as Lugar, 'resellers' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal)  as rango,
avg(LineTotal) as media,
round(stdev(LineTotal), 2) as desviacion_estandard,
round(exp(avg(log(LineTotal))),2) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID 
WHERE OnlineOrderFlag = 0
GROUP BY t.Name, t.[Group] 
UNION
SELECT t.Name as Zona, t.[Group]  as Lugar, 'ventas_online' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal) as rango,
avg(LineTotal) as media,
round(stdev(LineTotal), 2) as desviacion_estandard,
round(exp(avg(log(LineTotal))),2) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID 
WHERE OnlineOrderFlag = 1
GROUP BY t.Name, t.[Group] 
ORDER BY 1, 2, 3;


SELECT t.[Group]  as Lugar, 'resellers' as Tipo_compra, count(h.SalesOrderID) as cantidad_ventas,
FORMAT(sum(h.TotalDue), 'C') as monto_total
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
WHERE OnlineOrderFlag = 0
GROUP BY t.[Group]
UNION
SELECT t.[Group]  as Lugar, 'ventas_online' as Tipo_compra,  count(h.SalesOrderID) as cantidad_ventas,
FORMAT(sum(h.TotalDue), 'C') as monto_total
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
WHERE OnlineOrderFlag = 1
GROUP BY t.[Group] 
ORDER BY 4 DESC;
 
------------otra forma más fácil
 
SELECT t.[Group]  as Lugar, OnlineOrderFlag, count(h.SalesOrderID) as cantidad_ventas,
FORMAT(sum(h.TotalDue), 'C') as monto_total
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
GROUP BY t.[Group], OnlineOrderFlag;
 
 
 --Gráficos
SELECT t.[Group]  as Lugar,  count(h.SalesOrderID) as cantidad_ventas,
FORMAT(sum(h.TotalDue), 'C') as monto_total
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
WHERE OnlineOrderFlag = 1
GROUP BY t.[Group] 
ORDER BY 3 DESC;

SELECT t.[Group]  as Lugar,  count(h.SalesOrderID) as cantidad_ventas,
FORMAT(sum(h.TotalDue), 'C') as monto_total
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
WHERE OnlineOrderFlag = 2
GROUP BY t.[Group] 
ORDER BY 3 DESC;


SELECT t.[Group] as Lugar, 'resellers' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal)  as rango,
avg(LineTotal) as media,
round(stdev(LineTotal), 2) as desviacion_estandard,
round(exp(avg(log(LineTotal))),2) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID 
WHERE OnlineOrderFlag = 0
GROUP BY t.[Group] 
UNION
SELECT t.[Group]  as Lugar, 'ventas_online' as Tipo_compra, count(LineTotal) as cantidad,
count(distinct LineTotal) as cardinalidad,
max(LineTotal) - min(LineTotal) as rango,
avg(LineTotal) as media,
round(stdev(LineTotal), 2) as desviacion_estandard,
round(exp(avg(log(LineTotal))),2) as media_geometrica,
count(LineTotal) / Sum(1/LineTotal) as media_armonica
FROM Sales.SalesTerritory t INNER JOIN Sales.SalesOrderHeader h ON t.TerritoryID=h.TerritoryID
INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID 
WHERE OnlineOrderFlag = 1
GROUP BY t.[Group] 
ORDER BY 1, 2;


--Características Resellers 
--(Analizar características de los resellers que más venden)

--Total personas de ventas 18:
SELECT *
FROM HumanResources.vEmployeeDepartmentHistory 
WHERE Department = 'Sales';

--Datos laborales de ventas 18:
SELECT *
FROM HumanResources.Employee
WHERE BusinessEntityID IN (SELECT BusinessEntityID
                            FROM HumanResources.vEmployeeDepartmentHistory 
                            WHERE Department = 'Sales');

--Nivel organizacional y rol:
SELECT DISTINCT OrganizationLevel, JobTitle
FROM HumanResources.Employee
WHERE BusinessEntityID IN (SELECT BusinessEntityID
                            FROM HumanResources.vEmployeeDepartmentHistory 
                            WHERE Department = 'Sales');

--Total resellers que vendieron 17:
SELECT DISTINCT(SalesPersonID) 
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL;

--Persona restante (Vice presidente de ventas):
SELECT *
FROM HumanResources.vEmployeeDepartmentHistory h INNER JOIN HumanResources.Employee e ON h.BusinessEntityID=e.BusinessEntityID
WHERE h.BusinessEntityID NOT IN (SELECT SalesPersonID
                                FROM Sales.SalesOrderHeader
                                WHERE SalesPersonID IS NOT NULL)
AND Department = 'Sales';
 
--Total órdenes por resellers:
SELECT SalesPersonID, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID
ORDER BY Cantidad_ordenes DESC;

--Sumamos el rol y nivel que tienen
SELECT SalesPersonID, OrganizationLevel, JobTitle, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID, OrganizationLevel, JobTitle
ORDER BY Cantidad_ordenes DESC;

--TOP 10 mayor cantidad de ventas por reseller, año y mes
SELECT TOP 10 SalesPersonID,  OrganizationLevel, JobTitle, YEAR(OrderDate) Año, MONTH(OrderDate) Mes, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID,  OrganizationLevel, JobTitle, YEAR(OrderDate), MONTH(OrderDate) 
ORDER BY Cantidad_ordenes DESC;

--Cantidad de ventas por Managers, año y mes
SELECT SalesPersonID,  OrganizationLevel, JobTitle, YEAR(OrderDate) Año, MONTH(OrderDate) Mes, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
AND JobTitle != 'Sales Representative'
GROUP BY SalesPersonID,  OrganizationLevel, JobTitle, YEAR(OrderDate), MONTH(OrderDate) 
ORDER BY Cantidad_ordenes DESC;

--Gráficos
SELECT YEAR(OrderDate) AS Año, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
AND JobTitle = 'North American Sales Manager'
GROUP BY YEAR(OrderDate)
ORDER BY Año;

SELECT YEAR(OrderDate) AS Año, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
AND JobTitle = 'European Sales Manager'
GROUP BY YEAR(OrderDate)
ORDER BY Año; 

SELECT YEAR(OrderDate) AS Año, COUNT(*) Cantidad_ordenes
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
AND JobTitle = 'Pacific Sales Manager'
GROUP BY YEAR(OrderDate)
ORDER BY Año; 


--TOP 5 resellers con mayores montos vendidos
SELECT TOP 5 SalesPersonID, OrganizationLevel, JobTitle, FORMAT(SUM(TotalDue), 'C') Monto_total
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID, OrganizationLevel, JobTitle
ORDER BY Monto_total DESC;

--De dónde son los resellers que realizaron más de 250 ventas totales
SELECT SalesPersonID, t.Name AS Zona, t.[Group] AS Lugar
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesPerson p ON h.SalesPersonID=p.BusinessEntityID 
INNER JOIN Sales.SalesTerritory t ON p.TerritoryID=t.TerritoryID
GROUP BY SalesPersonID, t.Name, t.[Group]
HAVING COUNT(SalesOrderID) IN (SELECT COUNT(*) Cantidad_ordenes
                                    FROM Sales.SalesOrderHeader h1
                                    WHERE SalesPersonID IS NOT NULL
                                    GROUP BY SalesPersonID
                                    HAVING COUNT(*)>250)
ORDER BY COUNT(SalesOrderID) DESC;
 


--Datos lugar y telefono de todos los resellers (vista)
SELECT *
FROM sales.vSalesPerson;


--DATAFRAME con características de Resellers
WITH Resellers AS
(
SELECT SalesPersonID, CONCAT(pp.FirstName, ' ', pp.LastName) as Reseller, t.Name as Zona, t.[Group] as Lugar, e.JobTitle, v.Department, v.GroupName, e.BirthDate, e.MaritalStatus, e.Gender, e.HireDate, v.StartDate
FROM Sales.SalesOrderHeader h INNER JOIN HumanResources.Employee e ON h.SalesPersonID=e.BusinessEntityID 
INNER JOIN Person.Person pp ON e.BusinessEntityID=pp.BusinessEntityID
INNER JOIN HumanResources.vEmployeeDepartment v ON pp.BusinessEntityID=v.BusinessEntityID
INNER JOIN Sales.SalesPerson p ON v.BusinessEntityID =p.BusinessEntityID 
INNER JOIN Sales.SalesTerritory t ON p.TerritoryID=t.TerritoryID
GROUP BY SalesPersonID, CONCAT(pp.FirstName, ' ', pp.LastName), t.Name, t.[Group] , e.JobTitle, v.Department, v.GroupName, e.BirthDate, e.MaritalStatus, e.Gender, e.HireDate, v.StartDate
--ESTO AGREGAR SI SOLO QUEREMOS LOS QUE MAS VENDIERON:
--HAVING COUNT(SalesOrderID) IN (SELECT COUNT(*) Cantidad_ordenes
--                                    FROM Sales.SalesOrderHeader h1
--                                    WHERE SalesPersonID IS NOT NULL
--                                    GROUP BY SalesPersonID
--                                    HAVING COUNT(*)>250)
--ORDER BY COUNT(SalesOrderID) DESC;
)
 
SELECT*, DATEDIFF(D, StartDate, HireDate) as Datediff, DATEDIFF (YEAR, BirthDate, HireDate) as Edad
FROM Resellers;

-- Segmentado por género
--SELECT Gender, COUNT(*) Resellers
--FROM Resellers
--GROUP BY Gender;

-- Segmentado por edad
--SELECT DATEDIFF (YEAR, BirthDate, HireDate) as Edad, COUNT(*) Resellers
--FROM Resellers
--GROUP BY DATEDIFF (YEAR, BirthDate, HireDate);

-- Segmentado por lugar
--SELECT Lugar, COUNT(*) Resellers
--FROM Resellers
--GROUP BY Lugar;


-- DATAFRAME con características de consumos de productos

SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
--WHERE OnlineOrderFlag=1 para filtrar por tipo_compra
ORDER BY CustomerID;
 
 
--No hay compras onlines y físicas por el mismo cliente:

WITH compras_clientes AS
(
SELECT CustomerID, COUNT(OnlineOrderFlag) cantidad_compras, SUM(TotalDue) monto_compras, 'física' as tipo_compra
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY CustomerID
UNION
SELECT CustomerID, COUNT(OnlineOrderFlag) cantidad_compras, SUM(TotalDue) monto_compras, 'online' as tipo_compra
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
GROUP BY CustomerID
--ORDER BY 1
)
 
SELECT *, DENSE_RANK() OVER (ORDER BY CustomerID) control_cliente_duplicado
FROM compras_clientes;
 

-- EDA productos

WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE OnlineOrderFlag=0 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT MAX(UnitPrice) producto_mas_caro, MIN(UnitPrice) producto_menos_caro, AVG(UnitPrice) media_precio,
MAX(Productos_x_anio) maxima_cantidad_x_anio, MAX(Gastos_x_anio) maximo_gasto_x_año, MAX(Total_productos) maxima_cantidad_total, 
MAX(Total_gastos) gasto_maximo_total, MIN(Total_gastos) gasto_minimo_total
FROM Productos;


--Producto más caro comprado y frecuencia
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE OnlineOrderFlag=1 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT ProductID, Producto, Subcategoria, Categoria, UnitPrice, COUNT(ProductID) Frecuencia
FROM Productos 
WHERE UnitPrice = (SELECT MAX(p.UnitPrice)
                    FROM Productos p)
GROUP BY ProductID, Producto, Subcategoria, Categoria, UnitPrice
HAVING COUNT(ProductID) >= ALL (SELECT COUNT(pr.ProductID)
                                FROM Productos pr
                                WHERE pr.UnitPrice = (SELECT MAX(pr1.UnitPrice)
                                                        FROM Productos pr1)
                                GROUP BY pr.ProductID);


--Producto menos caro y frecuencia
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE OnlineOrderFlag=0 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT ProductID, Producto, Subcategoria, Categoria, UnitPrice, COUNT(ProductID) Frecuencia
FROM Productos
WHERE UnitPrice = (SELECT MIN(p.UnitPrice)
                    FROM Productos p)
GROUP BY ProductID, Producto, Subcategoria, Categoria, UnitPrice;


--Productos más frecuentes 
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
--WHERE OnlineOrderFlag=0 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT ProductID, Producto, Subcategoria, Categoria, UnitPrice, COUNT(ProductID) Frecuencia, OnlineOrderFlag
FROM Productos 
GROUP BY ProductID, Producto, Subcategoria, Categoria, UnitPrice, OnlineOrderFlag
ORDER BY Frecuencia DESC;


--Productos menos frecuentes 
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE OnlineOrderFlag=0 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT ProductID, Producto, Subcategoria, Categoria, UnitPrice, COUNT(ProductID) Frecuencia
FROM Productos 
GROUP BY ProductID, Producto, Subcategoria, Categoria, UnitPrice
ORDER BY Frecuencia;


--Cliente que más compró
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
--WHERE OnlineOrderFlag=1 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT DISTINCT CustomerID, t.[Group] AS Lugar, OnlineOrderFlag, SalesPersonID, d.JobTitle
FROM HumanResources.vEmployeeDepartment d INNER JOIN Productos p ON d.BusinessEntityID=p.SalesPersonID
INNER JOIN Sales.SalesTerritory t ON p.TerritoryID=t.TerritoryID
WHERE Total_productos = (SELECT MAX(p1.Total_productos)
                            FROM Productos p1);

SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE CustomerID=29722 AND SalesPersonID=274;


--Cliente que más gastó
WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
--WHERE OnlineOrderFlag=1 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT DISTINCT CustomerID, t.[Group] AS Lugar, OnlineOrderFlag, SalesPersonID, d.JobTitle
FROM HumanResources.vEmployeeDepartment d INNER JOIN Productos p ON d.BusinessEntityID=p.SalesPersonID
INNER JOIN Sales.SalesTerritory t ON p.TerritoryID=t.TerritoryID
WHERE Total_gastos = (SELECT MAX(p1.Total_gastos)
                            FROM Productos p1);


SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
WHERE CustomerID=29818 AND SalesPersonID=274;


-- Consumos de categorías más frecuentes por tipo de compra

WITH Productos AS

(
SELECT CustomerID, OnlineOrderFlag, SalesPersonID, TerritoryID, YEAR(OrderDate) AS Anio, MONTH(OrderDate) AS Mes, d.ProductID, p.Name AS Producto,
c.Name AS Categoria, ps.Name AS Subcategoria, UnitPrice, COUNT(d.ProductID) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Productos_x_anio,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate) ) Gastos_x_anio,
COUNT(d.ProductID) OVER (PARTITION BY CustomerID) Total_productos,
SUM(d.LineTotal) OVER (PARTITION BY CustomerID) Total_gastos
FROM Sales.SalesOrderHeader h INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID=d.SalesOrderID
INNER JOIN Production.Product p ON d.ProductID=p.ProductID 
INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID=ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory c ON ps.ProductCategoryID=c.ProductCategoryID
--WHERE OnlineOrderFlag=1 -- para filtrar por tipo_compra
--ORDER BY CustomerID;
)

SELECT Categoria, OnlineOrderFlag, COUNT(*) Consumos
FROM Productos
GROUP BY Categoria, OnlineOrderFlag
ORDER BY Categoria, OnlineOrderFlag;
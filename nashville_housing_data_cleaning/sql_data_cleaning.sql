/*
Cleaning Data in SQL Queries
*/
use portfolio_project;
select *from nashville_housing;

--------------------------------------------------------------------------------------------------

/*
Standardize Date Format
*/

select saledateconverted,date(saledate)as sale_date_only
from nashville_housing;

SET SQL_SAFE_UPDATES = 0;

update nashville_housing
set saledate = date(saledate);

alter table nashville_housing
add saledateconverted date;

update nashville_housing
set saledateconverted = date(saledate);

select * from nashville_housing;

---------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select*
from nashville_housing
-- where propertyaddress is null
order by parcelid;

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ifnull(a.propertyaddress,b.propertyaddress)as merged_address
from nashville_housing a
join nashville_housing b
on a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;

update nashville_housing a
join nashville_housing b
on a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
set a.PropertyAddress = ifnull(a.propertyaddress,b.propertyaddress)
where a.propertyaddress is null;

---------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select propertyaddress
from nashville_housing;

select
substring(propertyaddress,1,locate(',',propertyaddress)-1)as address,
substring(propertyaddress,locate(',',propertyaddress)+1,length(propertyaddress))as address
from nashville_housing;

alter table nashville_housing
add propertysplitaddress varchar(250);

update nashville_housing
set propertysplitaddress = substring(propertyaddress,1,locate(',',propertyaddress)-1);

alter table nashville_housing
add propwrtysplitcity varchar(250);

update nashville_housing
set propwrtysplitcity = substring(propertyaddress,locate(',',propertyaddress)+1,length(propertyaddress));

select * from nashville_housing;


select OwnerAddress
from nashville_housing;

select 
substring_index(OwnerAddress, ',',1),
substring_index(substring_index(OwnerAddress, ',',2), ',',-1),
substring_index(OwnerAddress, ',',-1)
from nashville_housing;


alter table nashville_housing
add ownerspiltaddress varchar(250);

update nashville_housing
set ownerspiltaddress = substring_index(OwnerAddress, ',',1);

alter table nashville_housing
add ownerspiltcity varchar(250);

update nashville_housing
set ownerspiltcity = substring_index(substring_index(OwnerAddress, ',',2), ',',-1);

alter table nashville_housing
add ownerspiltstate varchar(250);

update nashville_housing
set ownerspiltstate = substring_index(OwnerAddress, ',',-1);

select * from nashville_housing;

-------------------------------------------------------------------------------------------------------------------

-- Change Y And N to Yes and No in "Sold as Vacant" field
select SoldAsVacant
from nashville_housing;

select distinct(SoldAsVacant),count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant
order by 2;


select SoldAsVacant,
	 case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
	 from nashville_housing;


	update nashville_housing
	set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end;


	select * from nashville_housing;

---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
DELETE nh1
FROM nashville_housing nh1
JOIN (
    SELECT 
        MIN(UniqueID) AS keep_id,
        ParcelID, 
        PropertyAddress, 
        SalePrice, 
        SaleDate, 
        LegalReference
    FROM nashville_housing
    GROUP BY 
        ParcelID, 
        PropertyAddress, 
        SalePrice, 
        SaleDate, 
        LegalReference
) nh2
ON nh1.ParcelID = nh2.ParcelID
AND nh1.PropertyAddress = nh2.PropertyAddress
AND nh1.SalePrice = nh2.SalePrice
AND nh1.SaleDate = nh2.SaleDate
AND nh1.LegalReference = nh2.LegalReference
AND nh1.UniqueID <> nh2.keep_id;

SELECT  
    ParcelID,  
    PropertyAddress,  
    SalePrice,  
    SaleDate,  
    LegalReference,  
    COUNT(*) AS count
FROM nashville_housing
GROUP BY  
    ParcelID,  
    PropertyAddress,  
    SalePrice,  
    SaleDate,  
    LegalReference
HAVING COUNT(*) > 1;


	SELECT COUNT(*) FROM nashville_housing;

------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
select * from nashville_housing;

alter table nashville_housing
drop column propertyaddress,
drop column owneraddress,
drop column taxdistrict;

alter table nashville_housing
drop column saledate;

select * from nashville_housing;
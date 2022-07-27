/*

Data Cleaning in SQL

*/

select *
from Housing..house_def

-- Cahnge to standerize date format

select saledate,cast(SaleDate as date)
from Housing..house_def

---- Update directly

update Housing..house_def
set SaleDate=cast(SaleDate as date)

---- by adding new column

ALTER TABLE Housing..house_def
add SaleDateConevrt Date;

update Housing..house_def
set SaleDateConevrt=cast(SaleDate as date)

select SaleDateConevrt,cast(SaleDate as date)
from Housing..house_def

-- populate property address data
-- modify NULL Addresses by the address of same ParcelID

select *
from Housing..house_def
--where PropertyAddress is NULL
order by ParcelID

select nul.ParcelID, nul.PropertyAddress, mfy.ParcelID, mfy.PropertyAddress, ISNULL(nul.PropertyAddress,mfy.PropertyAddress)
from Housing..house_def nul
join Housing..house_def mfy
	on nul.ParcelID=mfy.ParcelID
	and nul.[UniqueID ]<>mfy.[UniqueID ]
where nul.PropertyAddress is NULL

update nul
set PropertyAddress=ISNULL(nul.PropertyAddress,mfy.PropertyAddress)
from Housing..house_def nul
join Housing..house_def mfy
	on nul.ParcelID=mfy.ParcelID
	and nul.[UniqueID ]<>mfy.[UniqueID ]
where nul.PropertyAddress is NULL

---- for Default value on NULL

update Housing..house_def
set PropertyAddress=ISNULL(PropertyAddress,'NO Address')

-- Breaking out address into individual columns (Address, city, state)

select PropertyAddress
from Housing..house_def

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address2
from Housing..house_def	

alter table Housing..house_def
add PropertyAddressStr nvarchar(255)

update Housing..house_def
set PropertyAddressStr=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table Housing..house_def
add PropertyAddressCity nvarchar(255);

update Housing..house_def
set PropertyAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select PropertyAddressStr,PropertyAddressCity
from Housing..house_def

---- Short way to Split Column
---- Parsenmae split by '.' and split backwards
select OwnerAddress
from Housing..house_def

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Housing..house_def

alter table housing..house_def
add OwnerAddressSplit nvarchar(255)

update Housing..house_def
set OwnerAddressSplit=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table housing..house_def
add OwnerAddressCity nvarchar(255)

update Housing..house_def
set OwnerAddressCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table housing..house_def
add OwnerAddressState nvarchar(255)

update Housing..house_def
set OwnerAddressState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from Housing..house_def

-- Change Y and N to Yes and No in "Sold vs Vaccant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from Housing..house_def
group by SoldAsVacant

select SoldAsVacant
, CASE when SoldAsVacant='Y' Then 'Yes'
		when SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
		End
from Housing..house_def

update Housing..house_def
set SoldAsVacant= CASE when SoldAsVacant='Y' Then 'Yes'
		when SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
		End


-- Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyAddress,
				 salePrice,
				 saleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from Housing..house_def
)
--select *
--From RowNumCTE
--where row_num>1

DELETE
From RowNumCTE
where row_num>1

-- delete unused columns

select * 
from housing..house_def

ALTER TABLE housing..house_def
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


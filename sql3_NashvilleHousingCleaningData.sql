/*
Cleaning data in SQL Queries
*/

select *
from project3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------

--- Standardize Data Format

select SaleDateConverted, CONVERT(date, SaleDate)
from project3.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------

--- Populate Property Address data

select *
from project3.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from project3.dbo.NashvilleHousing a
JOIN project3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from project3.dbo.NashvilleHousing a
JOIN project3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from project3.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
	LEN(PropertyAddress)) as Address
from project3.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, 
	CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, 
	CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select *
from project3.dbo.NashvilleHousing


---------

select OwnerAddress
from project3.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from project3.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



select *
from project3.dbo.NashvilleHousing



---------------------------------------------------------------------------------------

--- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from project3.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from project3.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from project3.dbo.NashvilleHousing


---------------------------------------------------------------------------------------

--- Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from project3.dbo.NashvilleHousing
--order by ParcelID
)
delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress



---------------------------------------------------------------------------------------

--- Delete Unused Columns

select *
from project3.dbo.NashvilleHousing


ALTER TABLE project3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE project3.dbo.NashvilleHousing
DROP COLUMN SaleDate


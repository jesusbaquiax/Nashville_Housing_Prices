-- Inspect

SELECT * 
FROM Nashville_Housing;


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT * 
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;


/* Populate Property Address Data */

SELECT *
FROM Nashville_Housing
WHERE PropertyAddress IS NULL;

SELECT *
FROM Nashville_Housing
ORDER BY ParcelID;

-- check nulls

SELECT A.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Nashville_Housing AS A
JOIN Nashville_Housing AS B 
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- replace nulls with property address

UPDATE A
SET PropertyAddress = ISNULL(A.propertyaddress, B.PropertyAddress)
FROM Nashville_Housing AS A
JOIN Nashville_Housing AS B 
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- check if nulls where replaced

SELECT A.ParcelID, 
	A.PropertyAddress, 
	B.ParcelID, 
	B.PropertyAddress 
FROM Nashville_Housing AS A
JOIN Nashville_Housing AS B 
	ON A.ParcelID = B.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ];



/* Breaking Address into individual columns (address, city, state) */


-- inspect addresses (delimiter between address and city is a comma)

SELECT PropertyAddress 
FROM Nashville_Housing;


-- create address and city colums

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NvarChar(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NvarChar(255); 

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- confirm address and city split columns were created

SELECT *
FROM Nashville_Housing;


/* OWNER ADDRESS */


-- Add split columns

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

-- populate split columns with relevant info

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- confirm split

SELECT *
FROM Nashville_Housing;


/* Change Yes & No to Y & N in SoldAsVacant Column */

-- look at count of unique values in SoldAsVacant columns.

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY Count DESC;

-- Values need to be consolidated to two majority values

UPDATE Nashville_Housing
SET SoldAsVacant =  
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville_Housing;

-- confirm change has taken place

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY Count DESC;


/* Remove Duplicates */


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- Confirm duplicates have been removed 

Select *
From Nashville_Housing;

/* Delete Unused Columns */

-- Inspect table and determing that OwnerAddress, TaxDistrict, PropertyAddress, and SaleDate columns can be dropped.

Select *
From Nashville_Housing;

-- Drop columns

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-- Confirm columns have been dropped

Select *
From Nashville_Housing;
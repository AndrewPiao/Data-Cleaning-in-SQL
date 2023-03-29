SELECT *
FROM [Portfolio Project 01]..NashvilleHousing

--Change/Standarize sale date---------------------------------------

ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD sale_date_converted Date;

UPDATE [Portfolio Project 01]..NashvilleHousing
SET Sale_Date_Converted = CONVERT(date,saledate)

SELECT Sale_Date_Converted
FROM [Portfolio Project 01]..NashvilleHousing

-- Populate Property Address Data-----------------------------------

SELECT *
FROM [Portfolio Project 01]..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelId

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 01]..NashvilleHousing a
JOIN [Portfolio Project 01]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project 01]..NashvilleHousing a
JOIN [Portfolio Project 01]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Splitting address into address, city------------------------------------

SELECT PropertyAddress
FROM [Portfolio Project 01]..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelId

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM [Portfolio Project 01]..NashvilleHousing
--
ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD SplitAddress Nvarchar(255);

UPDATE [Portfolio Project 01]..NashvilleHousing
SET SplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 
--
ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD SplitCity Nvarchar(255);

UPDATE [Portfolio Project 01]..NashvilleHousing
SET SplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT OwnerAddress
FROM [Portfolio Project 01]..NashvilleHousing

--Splitting OwnerAddress into address, city, state-------------------------------

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as SplitOwnerAddress
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as SplitOwnerCity
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as SplitOwnerState
FROM [Portfolio Project 01]..NashvilleHousing

ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD NewOwnerAddress Nvarchar(255);

UPDATE [Portfolio Project 01]..NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 

ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD NewOwnerCity Nvarchar(255);

UPDATE [Portfolio Project 01]..NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Portfolio Project 01]..NashvilleHousing
ADD NewOwnerState Nvarchar(255);

UPDATE [Portfolio Project 01]..NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--Changint y and N to Yes and No in 'Sold as Vacant' field---------------------

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) as Count
FROM [Portfolio Project 01]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project 01]..NashvilleHousing

UPDATE [Portfolio Project 01]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Removing Duplicates------------------------------------------------------------

WITH RowNumCTE AS(
SELECT *
,ROW_NUMBER() OVER (
	PARTITION  BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
FROM [Portfolio Project 01]..NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

--Delete now redundant columns----------------------------------------------

SELECT *
FROM [Portfolio Project 01]..NashvilleHousing

ALTER TABLE [Portfolio Project 01]..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict
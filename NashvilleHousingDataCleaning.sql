SELECT TOP 1000 * FROM PortfolioProject.dbo.NashvilleHousing

-- Registers number
SELECT COUNT(UniqueID)
FROM PortfolioProject.dbo.NashvilleHousing
-- / 56477 Registers

-- Columns number
SELECT COUNT(COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'
-- / 19 Columns

-- Get Data types
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'

-- Get Data types
SELECT DATA_TYPE, COUNT(COLUMN_NAME) as DataTypeCount
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing'
GROUP BY DATA_TYPE
/**
	datetime: 1
	float: 10
	nvarchar: 8
**/


/** Standardize Date format **/
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If update statement does not work
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date  -- Be careful with update statement


/** Populate Property Address data **/

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- There are Null values, how many?
SELECT COUNT(CASE WHEN PropertyAddress IS NULL THEN 1 END) AS CountNullValues
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
-- /29 Null Values

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS A
JOIN PortfolioProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- 
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS A
JOIN PortfolioProject.dbo.NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/** Breaking out Address into Individual Columns (Address, City, State) **/

-- Breaking out Property Address
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity, TRIM(PropertySplitCity)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = TRIM(PropertySplitCity)

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing

-- Breaking out Owner Address
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

/** Change Y and N to Yes and No in “Sold as vacant” field **/
SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SoldAsVacant, COUNT(SoldAsVacant) as CountValues
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = (
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
)

SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing

--Remove Duplicates

WITH RowNumCTE AS (
	SELECT 
		*,
		ROW_NUMBER() OVER (
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
		) AS row_num
	FROM PortfolioProject.dbo.NashvilleHousing
) SELECT * FROM RowNumCTE WHERE row_num > 1

--Delete Unused Columns

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

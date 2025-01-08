/*
Data Cleaning
*/

SELECT *
FROM PortfolioProject..NashvilleHousing;
-- ----------------------------------------------------------------------------------------------------

-- 1. Date-time Format
-- Set 'SaleDate' to date alone

SELECT 
	SaleDate,
	CONVERT(Date, SaleDate) 
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);
-- ------------------------------------------------------------------------------------------------------

-- 2. Populate NULL Values
--Fill in NULLs in 'PropertyAddress' with values from shared 'ParcelID'

SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
-- -------------------------------------------------------------------------------------------------------

-- 3. Split Column
-- Split 'PropertyAddress' to individual columns (Address, City)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Split 'OwnerAddress' to columns (Address, City, and State)

SELECT 
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing
--WHERE OwnerAddress IS NOT NULL;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-- ----------------------------------------------------------------------------------------------------------

-- 4. Edit Fields
-- Change 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsvacant' column

SELECT 
	DISTINCT SoldAsVacant,
	COUNT(SoldAsVacant) AS Entries
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant;

SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
-- ----------------------------------------------------------------------------------------------------------

-- 5. Remove Duplicates

WITH RowNumberCTE AS (
SELECT
	*,
	ROW_NUMBER() 
		OVER (
			PARTITION BY
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY
				UniqueID
				)RowNumber
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumberCTE
WHERE RowNumber > 1
ORDER BY PropertyAddress;

WITH RowNumberCTE AS (
SELECT
	*,
	ROW_NUMBER() 
		OVER (
			PARTITION BY
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY
				UniqueID
				)RowNumber
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumberCTE
WHERE RowNumber > 1
-- ORDER BY PropertyAddress;
-- ---------------------------------------------------------------------------------------------------------

-- 6. Delete Unused Columns
-- Delete columns ('PropertyAddress', 'OwnerAddress', 'TaxDistrict')

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

SELECT *
FROM PortfolioProject..NashvilleHousing
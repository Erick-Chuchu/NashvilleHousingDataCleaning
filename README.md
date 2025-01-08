# SQL Data Cleaning for Nashville Housing Dataset

## Description
This project contains a series of SQL scripts to clean and preprocess the **Nashville Housing** dataset. The dataset includes housing-related data, and the objective is to standardize, correct, and clean the data to ensure consistency and reliability for further analysis.

The SQL code focuses on the following tasks:
- **Date-Time Formatting**: Converting the `SaleDate` column to store only the date (no time).
- **Handling NULL Values**: Filling missing values in the `PropertyAddress` column by using related rows from the same `ParcelID`.
- **Column Splitting**: Splitting composite address columns into individual components for better data analysis.
- **Data Editing**: Converting categorical values to more user-friendly formats (e.g., 'Y' and 'N' to 'Yes' and 'No').
- **Removing Duplicates**: Identifying and removing duplicate records based on unique identifiers.
- **Deleting Unused Columns**: Dropping columns that are no longer required for analysis.

## Features
- **Standardized Sale Date**: Ensures the `SaleDate` column only includes date values, not time.
- **Null Value Imputation**: Replaces missing property addresses based on the shared `ParcelID`.
- **Address Breakdown**: Splits address columns into multiple individual columns like `Address`, `City`, and `State`.
- **Data Transformation**: Converts short codes ('Y', 'N') in `SoldAsVacant` to more meaningful words ('Yes', 'No').
- **Duplicate Removal**: Removes duplicates from the dataset based on key columns.
- **Column Cleanup**: Deletes unnecessary columns to streamline the dataset.

## Installation

To execute the SQL scripts in your own environment, follow these steps:

### 1. **Prerequisites**
Ensure that you have the following installed:
- **SQL Server** (or a compatible SQL database platform).
- The **NashvilleHousing** dataset should be available in your database.

### 2. **Executing the SQL Scripts**

Run the following SQL commands to clean and preprocess the data:

1. **Date-Time Format Cleanup**:
   - `SaleDate` is converted to store only the date without time:
   ```SQL
       UPDATE NashvilleHousing
       SET SaleDate = CONVERT(Date, SaleDate);
   
2. **Handle NULL Values in `PropertyAddress`**:
-This script fills in NULL values in the `PropertyAddress` field using values from other rows with the same `ParcelID`:
 ```SQL
    UPDATE a
    SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
    FROM NashvilleHousing a
    JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress IS NULL;

3. **Splitting Address Columns**:
The `PropertyAddress` and `OwnerAddress` columns are split into separate columns like `Address`, `City`, and `State`:

```SQL
    ALTER TABLE NashvilleHousing
    ADD PropertySplitAddress nvarchar(255);
    
    UPDATE NashvilleHousing
    SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

4. **Data Transformation**:
-The `SoldAsVacant` column is updated to replace 'Y' with 'Yes' and 'N' with 'No':
```SQL
    UPDATE NashvilleHousing
    SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;

5. **Removing Duplicate Records**:
-Duplicates are identified and removed from the table based on key columns such as `ParcelID`, `PropertyAddress`, `SalePrice`, and `SaleDate`:
```SQL
    WITH RowNumberCTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) AS RowNumber
    FROM NashvilleHousing)
    DELETE FROM RowNumberCTE WHERE RowNumber > 1;

6. **Delete Unused Columns**:
-Unused columns like `PropertyAddress`, `OwnerAddress`, and `TaxDistrict` are removed to streamline the dataset:
```SQL
    ALTER TABLE NashvilleHousing
    DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

## Usage

Once the scripts are executed, you will have a cleaned dataset ready for analysis.
The dataset should now have:
    A standardized `SaleDate` column with only date values.
    Non-null values in the `PropertyAddress` column.
    Split `Address`, `City`, and `State` columns.
    A transformed `SoldAsVacant` column with 'Yes' and 'No' values.
    Duplicates removed from the dataset.
    Unnecessary columns removed.
You can run additional queries to analyze or report on the cleaned dataset.

## Contributing

I welcome contributions!
To contribute:
    Fork the repository.
    Create a new branch (git checkout -b feature-branch).
    Make your changes and add new features.
    Commit your changes (git commit -m 'Improved data cleaning').
    Push to your forked repository (git push origin feature-branch).
    Open a pull request.
    If you find any issues, please open an issue in the GitHub repository.

## Authors

Erick Chuchu Owino
AlexTheAnalyst

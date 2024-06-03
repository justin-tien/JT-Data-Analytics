/*
Cleaning data in SQL Queries
*/
SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format
SELECT SalesDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing 
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing 
SET SalesDateConverted = Convert(Date, SaleDate)

--Populate Property Address data
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into Individual columns (address, city, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress) ) as city
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = substring (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress) )


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing




SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing


SELECT SoldAsVacant,
CASE
When SoldAsVacant = 'Y' THEN 'YES'
When SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
When SoldAsVacant = 'Y' THEN 'YES'
When SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END


--REMOVE Duplicates
WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing

)

DELETE
FROM RowNumCTE
Where row_num >1

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--DELETE Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN Owneraddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
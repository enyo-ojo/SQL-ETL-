select * 
from PortfolioProject..NashvilleHousing

--- Standardize date format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
from PortfolioProject..NashvilleHousing

---populate property address
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--same parcel id seem to have same propertyaddresses so we can use this to fill the null vallues
select a.ParcelID,b.ParcelID, a.PropertyAddress, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- to fill it in(same id's with address) by creating a new column
select a.ParcelID,b.ParcelID, a.PropertyAddress, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) as updateAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--updating the nulls in original data
Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---Next breaking adress to city, state ...
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySpllitAddress NVarChar(255);

Update NashvilleHousing
SET PropertySpllitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) 


Alter Table NashvilleHousing
Add PropertySpllitCity NVarChar(255);

Update NashvilleHousing
SET PropertySpllitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

--owner adress: second method of splitting
select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(Replace(OwnerAddress, ',' , '.'), 3) as OwnerSplitAddress,
PARSENAME(Replace(OwnerAddress, ',' , '.'), 2) as OwnerCity,
PARSENAME(Replace(OwnerAddress, ',' , '.'), 1) as OwnerState
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress NVarChar(255);
Alter Table NashvilleHousing
Add OwnerSplitCity NVarChar(255);
Alter Table NashvilleHousing
Add OwnerSplitState NVarChar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)


---Changing y/n to yes/no
select distinct(SoldAsVacant), COUNT(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--- Remove duplicates
--partiion on thing that should be unique(ids)

With RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelId, 
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 order by
				   uniqueID
				   ) row_num
from PortfolioProject..NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1


With RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by parcelId, 
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 order by
				   uniqueID
				   ) row_num
from PortfolioProject..NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

--- Delete Unused columns

Alter Table nashvillehousing
Drop column owneraddress, taxdistrict, propertyaddress, saledate
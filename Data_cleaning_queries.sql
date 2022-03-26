

-- Cleaning data in SQL queries with Nashville housing data

Select * 
From portfolio_project..Nashville_housing




-- Remove the time in the SaleDate

Select SaleDate, CONVERT(Date, SaleDate)
From portfolio_project..Nashville_housing

ALTER TABLE Nashville_housing
Add SaleDateConverted Date;

Update Nashville_housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
From portfolio_project..Nashville_housing




-- Populate the null property address with corresponding parcel ID and different Unique ID

Select * 
From portfolio_project..Nashville_housing
where PropertyAddress is null
order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From portfolio_project..Nashville_housing A
JOIN portfolio_project..Nashville_housing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From portfolio_project..Nashville_housing A
JOIN portfolio_project..Nashville_housing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null




-- Seperating the property address (street, city) into their own column

Select PropertyAddress
From portfolio_project..Nashville_housing
--where PropertyAddress is null

Select 
PARSENAME(Replace(PropertyAddress, ',', '.'), 2),
PARSENAME(Replace(PropertyAddress, ',', '.'), 1)
From portfolio_project..Nashville_housing

ALTER TABLE Nashville_housing
Add PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255);

Update Nashville_housing
Set PropertySplitAddress = PARSENAME(Replace(PropertyAddress, ',', '.'), 2)

Update Nashville_housing
Set PropertySplitCity = PARSENAME(Replace(PropertyAddress, ',', '.'), 1)


Select * 
From portfolio_project..Nashville_housing




-- Seperating the owner address (street, city, state) into their own column

Select OwnerAddress
From portfolio_project..Nashville_housing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From portfolio_project..Nashville_housing


ALTER TABLE Nashville_housing
Add OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update Nashville_housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update Nashville_housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update Nashville_housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select * 
From portfolio_project..Nashville_housing




-- Change Y and N into Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From portfolio_project..Nashville_housing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 END
From portfolio_project..Nashville_housing

Update Nashville_housing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						END




-- Removing duplicate rows 

WITH RowNumCTE AS(
Select *,
	   ROW_NUMBER() over (PARTITION BY ParcelID,
									   PropertyAddress,
									   SalePrice,
									   SaleDate,
									   LegalReference
									   Order by UniqueID
									   ) row_num
From portfolio_project..Nashville_housing							
)

-- Delete 
Select * 
From RowNumCTE
where row_num > 1
order by ParcelID




-- Removing unused columns

Select * 
From portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing
Drop column OwnerAddress, PropertyAddress








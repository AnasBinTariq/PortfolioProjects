/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

Select SaleDate, CONVERT (Date, SaleDate)					/*** First Date was in DateTime Format ***/
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing				/*** SaleDate Column Data Type Changed from DateTime to Date Format ***/
Alter Column SaleDate Date

Select SaleDate
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Inner Join PortfolioProject..NashvilleHousing b
On a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
And a.[UniqueID ] <> b.[UniqueID ]

Update a
Set PropertyAddress = Isnull(a.PropertyAddress,b.PropertyAddress)	/*** 1st input to be populated with the 2nd input, it can also be a string ***/
From PortfolioProject..NashvilleHousing a
Inner Join PortfolioProject..NashvilleHousing b
On a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
And a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------------------------------------------------------------------------------

--BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (Address, City) USING SUBSTRING METHOD

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
PropertyAddress , 
Substring ( PropertyAddress, 1, Charindex (',', PropertyAddress) -1 )  As SplitPropertyAddress,
Substring ( PropertyAddress, Charindex (',', PropertyAddress) +1 , len(PropertyAddress) ) As SplitPropertyCity
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add SplitPropertyAddress nvarchar (255)

Update PortfolioProject..NashvilleHousing
Set SplitPropertyAddress = Substring ( PropertyAddress, 1, Charindex (',', PropertyAddress) -1 )

Alter Table PortfolioProject..NashvilleHousing
Add SplitPropertyCity nvarchar (255)

Update PortfolioProject..NashvilleHousing
Set SplitPropertyCity = Substring ( PropertyAddress, Charindex (',', PropertyAddress) +1 , len(PropertyAddress) )

Select *
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------

--EASIER METHOD OF SPLITING SINGLE COLUMN INTO MULTIPLE INDIVIDUAL COLUMNS

--BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (Address, City, State) USING PARSE (Breaking Sentence into Parts) METHOD

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select												/*** PARSENAME Operates on periods like '.' so first replace comma with period ***/
Parsename( Replace (OwnerAddress, ',', '.') , 3),   /*** PARSENAME starts looking special character like period from right side ***/
Parsename( Replace (OwnerAddress, ',', '.') , 2),   /*** PARSENAME that is why break sentence begining from right side ***/
Parsename( Replace (OwnerAddress, ',', '.') , 1)    /*** Now its giving us the break address in right order by putting index in desc order ***/
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add SplitOwnerAddress nvarchar (255)

Update PortfolioProject..NashvilleHousing
Set SplitOwnerAddress = Parsename( Replace (OwnerAddress, ',', '.') , 3)

Alter Table PortfolioProject..NashvilleHousing
Add SplitOwnerCity nvarchar (255)

Update PortfolioProject..NashvilleHousing
Set SplitOwnerCity = Parsename( Replace (OwnerAddress, ',', '.') , 2)

Alter Table PortfolioProject..NashvilleHousing
Add SplitOwnerState nvarchar (255)

Update PortfolioProject..NashvilleHousing
Set SplitOwnerState = Parsename( Replace (OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SoldAsVacant' FIELD 

Select SoldAsVacant
From PortfolioProject..NashvilleHousing

Select SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant =	Case 
						When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
					End

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

-------------------------------------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

--ROW_NUMBER in SQL
--The ROW_NUMBER() function in SQL assigns a sequential integer to each row within the partition of a result set. It starts with 1 for the first row in each partition

--Usage with PARTITION BY
--The PARTITION BY clause divides the result set into partitions to which the ROW_NUMBER() function is applied. The row number is reset whenever the partition boundary is crossed.

with RowNumCTE as
(
Select * ,
			Row_Number () 
			over 
			(
			partition by ParcelID, 
					      PropertyAddress, 
						  SalePrice, 
						  SaleDate, 
						  LegalReference 
						  order by UniqueID
			) row_numb
From PortfolioProject..NashvilleHousing
)

/*** Down Statement deleted all the duplicated records where row number shown greater than 1 ***/
--Delete
--From RowNumCTE
--Where row_numb > 1

/*** Down Statement checked all the duplicated records where row number shown greater than 1 now it has not been showing any duplicate records ***/
Select *
From RowNumCTE
Where row_numb > 1

-------------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

--Select *
--From PortfolioProject..NashvilleHousing

--Alter Table PortfolioProject..NashvilleHousing
--Drop Column PropertyAddress, OwnerAddress, TaxDistrict

-------------------------------------------------------------------------------------------------------------------------------------------------------


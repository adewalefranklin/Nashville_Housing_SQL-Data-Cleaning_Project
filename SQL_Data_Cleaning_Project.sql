--STEP 1 viewing the datasets

select* from projectportfolio..Nashville_sheet1$
order by ParcelID

--STEP 2 date format standardization

select SaleDate
from projectportfolio..Nashville_sheet1$

select SaleDate, CONVERT(Date, SaleDate) as Date
from projectportfolio..Nashville_sheet1$

update projectportfolio..Nashville_sheet1$
set SaleDate = CONVERT(Date, SaleDate)

--OR

alter table  projectportfolio..Nashville_sheet1$
add converted_SaleDate date;

update projectportfolio..Nashville_sheet1$
set Converted_SaleDate = CONVERT(Date, SaleDate)

select Converted_SaleDate, CONVERT(Date, SaleDate)
from projectportfolio..Nashville_sheet1$


--STEP 3 populating the property address data where there are missing values (Null Values)

select *
from projectportfolio..Nashville_sheet1$ as nash1
inner join projectportfolio..Nashville_sheet1$ as nash2
on nash1.ParcelID=nash2.ParcelID
and nash1.[UniqueID ] != nash2.[UniqueID ]


select nash1.parcelid, nash1.propertyaddress, nash2.parcelid, nash2.propertyaddress,ISNULL(nash1.propertyaddress,nash2.propertyaddress)
from projectportfolio..Nashville_sheet1$ as nash1
inner join projectportfolio..Nashville_sheet1$ as nash2
on nash1.ParcelID=nash2.ParcelID
and nash1.[UniqueID ] != nash2.[UniqueID ]
where nash1.PropertyAddress IS NULL


update nash1
set PropertyAddress = ISNULL(nash1.propertyaddress,nash2.propertyaddress)
from projectportfolio..Nashville_sheet1$ as nash1
inner join projectportfolio..Nashville_sheet1$ as nash2
on nash1.ParcelID=nash2.ParcelID
and nash1.[UniqueID ] != nash2.[UniqueID ]
where nash1.PropertyAddress IS NULL


--STEP 4 separating address column into individual columns


select PropertyAddress from projectportfolio..Nashville_sheet1$
--where PropertyAddress is null
--order by ParcelID

select
substring(propertyaddress, 1, charindex(',' ,propertyaddress)-1) as Address,
substring(propertyaddress, charindex(',' ,propertyaddress)+1, LEN(propertyaddress)) as Address
from projectportfolio..Nashville_sheet1$



alter table  projectportfolio..Nashville_sheet1$
add property_split_address varchar(255);


update projectportfolio..Nashville_sheet1$
set property_split_address = substring(propertyaddress, 1, charindex(',' ,propertyaddress)-1)


alter table  projectportfolio..Nashville_sheet1$
add property_split_city varchar(255);


update projectportfolio..Nashville_sheet1$
set property_split_city = substring(propertyaddress, charindex(',' ,propertyaddress)+1, LEN(propertyaddress))


select* from projectportfolio..Nashville_Sheet1$


--STEP 5 splitting the ownerAddress column

select owneraddress from projectportfolio..Nashville_Sheet1$

select 
PARSENAME(replace(owneraddress,',', '.'),3),
PARSENAME(replace(owneraddress,',', '.'),2),
PARSENAME(replace(owneraddress,',', '.'),1)
from projectportfolio..Nashville_Sheet1$

alter table  projectportfolio..Nashville_sheet1$
add owner_split_address varchar(255);
update projectportfolio..Nashville_sheet1$
set owner_split_address = PARSENAME(replace(owneraddress,',', '.'),3)


alter table  projectportfolio..Nashville_sheet1$
add owner_split_city varchar(255);


update projectportfolio..Nashville_sheet1$
set owner_split_city = PARSENAME(replace(owneraddress,',', '.'),2)

alter table  projectportfolio..Nashville_sheet1$
add owner_split_state varchar(255);


update projectportfolio..Nashville_sheet1$
set owner_split_state = PARSENAME(replace(owneraddress,',', '.'),1)

select*
from
projectportfolio..Nashville_sheet1$


--STEP 6 changing 'Y' and 'N' to 'Yes' and 'No'



select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from projectportfolio..Nashville_sheet1$ -- to double check if the values are all the same or not
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant ='N' then 'No'
     else SoldAsVacant
	 end
from projectportfolio..Nashville_sheet1$

update projectportfolio..Nashville_sheet1$
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant ='N' then 'No'
     else SoldAsVacant
	 end

	 select distinct(SoldAsVacant)
	 from projectportfolio..Nashville_sheet1$


--STEP 7 Removing Duplicates


	 with row_numCTE as (
	 select*,
	 row_number() OVER (
	 partition by parcelid,
	              propertyaddress,
				  saleprice,
				  saledate,
				  legalreference
				  order by 
				  uniqueid
				  ) as row_num

	 from projectportfolio..Nashville_sheet1$
	-- order by ParcelID
	)
	--select* from row_numCTE -- to identify how many duplicate rows exist in the dataset
	--where row_num > 1 
	--order by propertyaddress

	--delete from row_numCTE -- to remove duplicate rows exist in the dataset
	--where row_num > 1 

	select* from row_numCTE -- to identify how many duplicate rows exist in the dataset
	where row_num > 1 
	order by propertyaddre

	
--STEP 8 Deleting unused column 

	alter table projectportfolio..Nashville_sheet1$
	drop column taxdistrict,owneraddress,propertyaddress

	select* from projectportfolio..Nashville_sheet1$

	alter table projectportfolio..Nashville_sheet1$
	drop column saledate

	select* from projectportfolio..Nashville_sheet1$
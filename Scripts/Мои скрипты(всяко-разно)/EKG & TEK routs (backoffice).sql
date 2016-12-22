/*
exec sp_Route_Get @uidSysUserID='CAC1DC68-C000-48EA-902C-3A49AE2A67FF',@iRouteID=NULL

exec sp_Route_Get @uidSysUserID='CAC1DC68-C000-48EA-902C-3A49AE2A67FF',@iRouteID=20,@iForItemEdit=1
exec sp_Route_Get @uidSysUserID='CAC1DC68-C000-48EA-902C-3A49AE2A67FF',@iRouteID=23,@iForItemEdit=0

exec sp_RouteNodeType_Get @uidSysUserID='CAC1DC68-C000-48EA-902C-3A49AE2A67FF',@iRouteNodeTypeID=NULL
*/
/****************************/
select
			--dr.iRouteID,
			dr.vcName as '������������ ��������',
			--vcDescription,
			--iVersion,
			--iIsAvalable,
			drg.vcName as '���� ��������',
			du.name as '������������ �� ����',
			dc.name as '������ � ��������',
			case 
				when rca.iPermissions = 0 then '������ ��������' 
				when rca.iPermissions = 1 then '������ ���������' 
				when rca.iPermissions = 2 then '������ �������'
				when rca.iPermissions = 3 then '��������� � �������'
				else  '=' 
			end as '��� ������� � ��������� �� ��������'
		from dic_Route dr
			join dic_RouteGroup drg on drg.iRouteID = dr.iRouteID
			join dic_RouteUser ru on ru.iRouteGroupID = drg.iRouteGroupID
			inner join dic_User du on ru.iUserID = du.user_id
			join dic_RouteCompanyAccess rca on rca.iRouteUserID = ru.iRouteUserID
			join dic_Company dc on rca.iCompanyID = dc.Company_ID
		where
			dr.iIsAvalable = 1
			and du.name not like '(������������)%'
			--and rca.iPermissions = 2
			--and dr.iRouteID=20
			--and dc.company_id in (26044, 26045, 26430)
			and du.user_id in (226)
		order by dr.vcName, drg.vcName, du.name


/********************    ��������� ����� ������������ ����� ���������           ***********************/
select * from dic_RouteUser
select * from dic_RouteCompanyAccess

select * from dic_user where name like '%�����%'
select * from dic_user where name like '%����%'

declare @newuserID int = 250, @olduserID int = 263

--select @newuserID, iRouteGroupID, iRouteNodeTypeID 
--delete from dic_RouteUser where iUserID = @newuserID
--SET IDENTITY_INSERT dic_RouteUser ON

--insert --����� �������� �� ��������
	into dic_RouteUser (iUserID, iRouteGroupID, iRouteNodeTypeID)
	(select @newuserID, iRouteGroupID, iRouteNodeTypeID 
		from dic_RouteUser where iUserID = @olduserID
	)
	
--SET IDENTITY_INSERT dic_RouteUser OFF


insert into dic_RouteCompanyAccess (iRouteUserID, iCompanyID, iPermissions, iUserID, iRouteGroupID)
	(
	select 
			--distinct rca.iRouteUserID
			--rca.iRouteUserID, rca.iCompanyID, rca.iPermissions , * 
			ru2.iRouteUserID, rca.iCompanyID, rca.iPermissions, @newuserID, rca.iRouteGroupID
		from dic_RouteCompanyAccess rca
			join dic_RouteUser ru1 on rca.iRouteUserID = ru1.iRouteUserID
			join dic_RouteUser ru2 
				on 
					ru2.iRouteGroupID = ru1.iRouteGroupID
					and ru2.iRouteNodeTypeID = ru1.iRouteNodeTypeID
					and ru2.iUserID = @newuserID
		where ru1.iUserID = @olduserID
	)
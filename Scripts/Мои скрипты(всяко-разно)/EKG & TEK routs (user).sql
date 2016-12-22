/*
----- all roles
select * from dic_signs ds

--update 
	dic_signs
		set
			name = '1. Инициатор',
			shortname = '1. Инициатор'
	where
		sign_id=16	



exec sp_AdmRoute_Get 
select * from dic_object
--------------
exec sp_AdmRouteOrderFieldRight_Get @iRouteID=100

select
		*
	from dic_RouteOrderFieldRight rofr
		join dic_signs ds on rofr.iSignID = ds.sign_id
	where iRouteID = 127
----------
exec sp_AdmRouteSigns_Get @iRouteID=100

select
		ds.sign_id as iSignID,
		dlr.line_id as iRouteID,
		ds.name as vcSignName,
		ds.shortname as vcSignShortName,

		case when isnull(dlr.line_rel_id, 0) != 0 then 1 else 0 end as iIsInRoute,
		isnull(drr.right_mask, 0) as iRightMask
	from
		dic_signs ds
		left join dic_line_rel dlr on dlr.sign_id = ds.sign_id and dlr.line_id = 127
		left join dic_right_rel drr on drr.line_rel_id = dlr.line_rel_id
		left join dic_line dl on dl.line_id = dlr.line_id
		
select * from 	dic_signs ds	
select * from 	dic_line_rel dlr where dlr.line_id = 100

select * from dic_right_rel drr

--------------
exec dbo.sp_AdmRouteRight_Get 

exec sp_AdmRouteUserRight_Get @iRouteID=100 --users on point

select
		du.user_id as iUserID,
		dlr.line_id as iRouteID,
		ds.sign_id as iSignID,
		du.shortname as vcUserShortName
		,*
	from
		dic_user du 
		left join dic_user_rel dur
			inner join dic_right_rel drr on drr.right_rel_id = dur.right_rel_id
			inner join dic_line_rel dlr on dlr.line_rel_id = drr.line_rel_id and dlr.line_id = 127
			inner join dic_signs ds on ds.sign_id = dlr.sign_id
		on du.user_id = dur.user_id

select * from dic_right_rel drr
select * from dbo.dic_right

select * from dic_user_rel
select * from dic_line_rel dlr
select * from dic_signs ds

select * from dic_user du
----------
exec sp_AdmRoutePoints_Get @iRouteID=100

--
exec sp_AdmRoutePointSigns_Get @iRouteID=100

select
		ds.sign_id as iSignID,
		dp.line_id as iRouteID,
		dp.point_id as iPointID
	from
		dic_signs ds
		inner join dic_line_rel dlr on dlr.sign_id = ds.sign_id and dlr.line_id = 127
		left join dic_points_rel dpr
			inner join dic_points dp on dpr.point_id = dp.point_id and dp.line_id = 127
		on dpr.sign_id = ds.sign_id 
		
select * from 	dic_line_rel	where line_id=127
select * from 	dic_points_rel dpr
select * from 	dic_points dp where line_id=127
--
exec sp_AdmRouteData_Get @iRouteID=100

select
		dld.row_id as iRowID,
		dld.line_id as iRouteID,
		dld.LevelPoint_id as iLevelPointID,
		dld.NotLevel_id as iRejectLevelID,
		dld.YesLevel_id as iAcceptLevelID,
		dld.StartPoint as iIsStartPoint,
		dld.EndPoint as iIsEndPoint,
		dld.ProcessPoint as iIsProcessPoint,
		dld.version_obj as iRouteVersion
	from
		dic_lineData dld
	where dld.line_id = 100
		order by dld.EndPoint
		
select * from dic_lineData dld where dld.line_id = 127
--
exec sp_AdmUserRouteCompany_Get @iRouteID=100

select
		urc.iRouteID,
		urc.iUserID,
		urc.iCompanyID
	from
		dic_UserRouteCompany urc
		inner join dic_user_rel dur
			inner join dic_right_rel drr on drr.right_rel_id = dur.right_rel_id
			inner join dic_line_rel dlr on dlr.line_rel_id = drr.line_rel_id and dlr.line_id = 127
			inner join dic_signs ds on ds.sign_id = dlr.sign_id
		on urc.iUserID = dur.user_id
	where
		iRouteID = 127

select * from dic_UserRouteCompany urc
select * from dic_company
select * from 	
*/

		
/****************
final select
******************/
select
		do.name as 'Тип заявки',
		--dl.line_id as iRouteID,
		--dl.shortname as vcShortName,
		dl.name as 'Наименование маршрута',
		--dl.obj_id as iObjectTypeID,s
		--dl.version_obj as iRouteVersion,
		--dl.vcDesc as vcDesc
		ds.name as 'Узел маршрута',
		du.name as 'Пользователь на узле',
		dc.name as 'Доступ к компании',
		case 
				when dld.StartPoint = 1 then 'Да' 				
				else  'Нет' 
			end as 'Начальный узел машрута',
		case 
				when dld.ProcessPoint = 1 then 'Да' 				
				else  'Нет' 
			end as 'Промежуточный узел машрута',
		case 
				when dld.EndPoint = 1 then 'Да' 				
				else  'Нет' 
			end as 'Конечный узел маршрута'
		
	from dic_line dl
		join dic_object do on dl.obj_id = do.obj_id	--tip zajavki	
		join dic_line_rel dlr on dlr.line_id = dl.line_id --roli na marshrute
		join dic_signs ds on dlr.sign_id = ds.sign_id --nazvanija uzlov
		
		join dic_points dp 
				join dic_points_rel dpr --svjaz' uzlov marshruta
					on dpr.point_id = dp.point_id
			on dpr.sign_id = ds.sign_id and dp.line_id = dl.line_id
		
		join dic_lineData dld on dld.LevelPoint_id = dp.point_id
		
		inner join dic_right_rel drr on dlr.line_rel_id = drr.line_rel_id and dlr.line_id = dl.line_id
		join dic_user_rel dur on drr.right_rel_id = dur.right_rel_id
		
		join dic_user du on du.user_id = dur.user_id
		
		join dic_UserRouteCompany urc on urc.iUserID = dur.user_id and urc.iRouteID = dl.line_id
		join dic_company dc on dc.company_id = urc.iCompanyID
		
	where	
		du.name not like '(Заблокирован)%'
		--and dl.line_id = 100
		and dc.company_id in (26044, 26045, 26430)
		and du.user_id in(186)
	order by do.name, dl.name, dld.LevelPoint_id, ds.name--dld.EndPoint



/********************    присвоить права пользователю после заведения           ***********************/
select * from dic_UserRouteCompany

select * from dic_user where name like '%Весел%'---226
select * from dic_user where name like '%Андри%'---186
select * from dic_user where name like '%Беля%'

declare @newuserID int = 250, @olduserID int = 263
select * from dic_user_rel where user_id = @olduserID
select * from dic_user_rel where user_id = @newuserID
--select * from dic_UserRouteCompany where iUserID = @olduserID
--select * from dic_UserRouteCompany where iUserID = @newuserID

--insert --чтобы случайно не вставить
	into dic_user_rel (user_id, right_rel_id)
	(select @newuserID, right_rel_id 
		from dic_user_rel where user_id = @olduserID
	)
	
insert 
	into dic_UserRouteCompany (iRouteID, iUserID, iCompanyID)
	(select iRouteID, @newuserID, iCompanyID 
		from dic_UserRouteCompany where iUserID = @olduserID
	)	
	
--declare @newuserID int = 304, @olduserID int = 260
insert into who_UserRouteCompany
	(iRouteID, iUserID, iCompanyID)
	(select iRouteID, @newuserID, iCompanyID 
		from who_UserRouteCompany where iUserID= @olduserID
	)

--select @newuserID, iRouteGroupID, iRouteNodeTypeID 
--delete
--		from dic_RouteUser where iUserID = @newuserID
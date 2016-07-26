create function dbo.GetFirstDateOfYear(@dt date)
returns date
as
begin
	return(select datefromparts(year(@dt), 1, 1));
end
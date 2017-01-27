#require -version 3
#require -module sqlps
<#
Create a table to insert the retrieved data into
use weather;
CREATE TABLE [dbo].[HeatingHistory](
	[ReadingDate] [date] NOT NULL,
	[HeatingDegreeDays] [int] NOT NULL,
	[LocState] [char](2) NOT NULL,
	[LocCity] [varchar](20) NOT NULL,
 CONSTRAINT [PK__HeatingHistory] PRIMARY KEY CLUSTERED
(
	[ReadingDate] ASC,
	[LocState] ASC,
	[LocCity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

select * from weather.dbo.HeatingHistory
#>
$MyAPIKey = "b20ed945140ca28e"
;
Set-StrictMode -Version latest;
[datetime]$WeatherDate = "2015-01-01";
while ($WeatherDate -lt (get-date)) {
    $WeatherURL = "http://api.wunderground.com/api/$MyAPIKey/history_$(get-date $WeatherDate -format "yyyyMMdd")/q/NY/Rochester.json"
    $WeatherData = invoke-webrequest -Uri $WeatherURL;
    $HeatingDegreeDays = "0" + ($WeatherData|ConvertFrom-Json).history.dailysummary.heatingdegreedays;
    invoke-sqlcmd -serverinstance "sql2014" -database Weather -query "insert into HeatingHistory values ('$WeatherDate',$HeatingDegreeDays, 'NY','Rochester')";
    $WeatherDate = $WeatherDate.AddDays(1);
# have to sleep 7 seconds here. WUnderground limits to 10 calls per minute
    start-sleep -Seconds 7
}

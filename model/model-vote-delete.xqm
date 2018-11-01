module namespace model = "http://www.iro37.ru/golosovalka/model";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $model:db-name := $data:dbName;

declare
  %updating 
  %rest:path( "/golosovalka/delete-vote" )
  %rest:query-param ( "master", "{ $master }" )
  %rest:GET
function model:update-vote ( $master )
{
  insert node $data:vote ( $master ) into $data:archive,
  delete node $data:vote ( $master ),
  db:output( web:redirect( "/golosovalka" ) )
};
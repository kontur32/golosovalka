module namespace model = "http://www.iro37.ru/golosovalka/model";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $model:db-name := $data:dbName;

declare
  %updating 
  %rest:path( "/golosovalka/update-vote" )
  %rest:query-param ( "master", "{ $master }" )
  %rest:query-param ( "questions", "{ $questions }" )
  %rest:query-param ( "title", "{ $title }" )
  %rest:query-param ( "quote", "{ $quote }" )
  %rest:GET
function model:update-vote ( $master, $questions, $title, $quote  )
{
  let $meta := 
    let $questions := 
      let $s := tokenize ( $questions, ';' ) 
      for $q in  1 to count ($s)
      return <question id="q{$q}">{ normalize-space ( $s[$q] ) }</question>
    return
    <meta>
      <title>{ $title }</title>
      <quote>{  $quote }</quote>
      <questions>{ $questions }</questions>
    </meta>
  
  let $data := $data:vote ( $master )
  return
    replace node $data//meta with $meta,
    db:output( web:redirect( 'master'  , map {"master": $master, "message":"Изменения успешно записаны"}) )
};
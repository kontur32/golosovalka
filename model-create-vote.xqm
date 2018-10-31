module namespace model = "http://www.iro37.ru/golosovalka/model";
import module namespace request = "http://exquery.org/ns/request";

declare variable $model:db-name := "golosovalka-dev";

declare 
  %updating 
  %rest:path("/golosovalka/create-vote")
  %rest:query-param ("type", "{$type}")
  %rest:query-param ("var", "{$var}")
  %rest:query-param ("counting", "{$counting}")
  %rest:GET
function model:create-vote ( $type, $var, $counting )
{
  let $hash := ( random:uuid(), random:uuid() )
  return
    model:new-vote ( $hash, $type, $var, $counting )
};

declare %updating function model:new-vote ( $hash, $type, $var, $counting )
{
   let $vote := 
      <vote 
        master="{$hash[1]}" 
        common = "{$hash[2]}" 
        time = "{current-dateTime()}"
        type = "{ $type }"
        var = "{ $var }"
        counting = "{ $counting }"
        >
        <meta/>
        <results/>
      </vote>
  return
       insert node $vote into db:open($model:db-name, 'data')/data,
       db:output(web:redirect( 'master'  , map {"master": $hash[1], "message":"Новый опрос успешно создан"}))
};
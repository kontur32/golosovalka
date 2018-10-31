module namespace model = "http://www.iro37.ru/golosovalka/model";

import module namespace request = "http://exquery.org/ns/request";

declare variable $model:db-name := "golosovalka-dev";

declare
  %updating 
  %rest:path("/golosovalka/update-result")
  %rest:GET
function model:update-result ()
{
  let $data := db:open( $model:db-name , 'data')/data/vote[ @common=request:parameter('common') ]
  return
  if ( count ( $data/results/result ) < $data/meta/quote/text()  )
  then (
    let $result := 
      <result>
        {
          for $i in request:parameter-names()
          where matches($i, 'q')
          return
            <question id="{$i}" value="{request:parameter($i)}" />
        }
      </result>
    return 
      insert node $result into $data/results,
      db:output(web:redirect( 'vote'  , map {"common": request:parameter('common'), "message":"Изменения успешно записаны"}))  
  )
  else (
    db:output(web:redirect( 'vote'  , map {"common": request:parameter('common'), "message":"Голосование завершено"})) 
  )    
};
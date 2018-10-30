module namespace model = 'http://www.iro37.ru/golosovalka/model';
import module namespace request = "http://exquery.org/ns/request";

declare variable $model:db-name := 'golosovalka-dev';

declare 
  %updating 
  %rest:path("/golosovalka/create-vote")
  %rest:GET
function model:create-vote ()
{
  let $hash := (random:uuid(), random:uuid())
  return
    model:new-vote ($hash)
};

declare %updating function model:new-vote ($hash)
{
   let $vote := 
      <vote 
        master="{$hash[1]}" 
        common = "{$hash[2]}" 
        time = "{current-dateTime()}">
        <meta/>
        <results/>
      </vote>
  return
       insert node $vote into db:open($model:db-name, 'data')/data,
       db:output(web:redirect( 'master'  , map {"master": $hash[1], "message":"Новый опрос успешно создан"}))
};

declare
  %updating 
  %rest:path("/golosovalka/update-vote")
  %rest:GET
function model:update-vote ()
{
  let $meta := 
    let $questions := 
      let $s := tokenize (request:parameter('questions'), ';') 
      for $q in  1 to count ($s)
      return <question id="q{$q}">{normalize-space ($s[$q])}</question>
    return
    <meta>
      <title>{request:parameter('title')}</title>
      <quote>{request:parameter('quote')}</quote>
      <questions>{ $questions }</questions>
    </meta>
  let $data := db:open($model:db-name , 'data')/data/vote[@master=request:parameter('master')]
  return
    replace node $data//meta with $meta,
    db:output(web:redirect( 'master'  , map {"master": request:parameter('master'), "message":"Изменения успешно записаны"}))
};

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
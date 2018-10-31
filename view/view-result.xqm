module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $view:db-name := $data:dbName;

declare 
  %rest:path("/golosovalka/result")
  %rest:GET
  %rest:query-param ( "common", "{ $common }" )
  %rest:query-param ( "message", "{ $message }" )
  %output:method( "xhtml" )
function view:result ( $common, $message )
{
  let $data := $data:vote ( $common )
  let $voteType := 
      if ( $data/@type = "single")
      then ( "один из" )
      else ( "несколько из" )
      
  let $countingType := 
      if ( $data/@counting = "simple")
      then ( "простое большинство" )
      else ( "квалифицированное большинство" ) 
  let $isNeutral := if ( $data/@var = "neutral" ) then ( true() ) else ( false () )  
  let $var := if ( $isNeutral ) then ( " / Воздержался" ) else ( )
  let $content :=     
      <div class="col">
        <h3>{$data//meta/title/text()}</h3>
        <p><i><b>Тип голосования: </b> { $voteType }</i></p>
        <p><i><b>Варинаты ответов: </b> За / Против { $var }</i></p>
        <p><i><b>Способ определения результата: </b> { $countingType }</i></p>
        <p><i><b>Голосовали участников: </b> {count( $data/results/result) }</i></p>
        <table class="table">
          <thead>
            <tr>
              <th>Вопрос</th>
              <th class="text-center">За</th>
              <th class="text-center">Против</th>
              {
                if ( $isNeutral)
                then (
                  <th class="text-center">Воздержались</th>
                )
                else ()
              }
              <th class="text-center">Результат</th>
            </tr>
          </thead>
          <tbody>
          {
            for $i in $data//questions/question
            let $qoute := $data/meta/quote/text()
            
            let $countResult := view:countResult ( $data, $i )
            
            let $countingQuote := if ( $data/@counting = "simple") then ( 0.5 ) else ( 2 div 3 )
            let $result := if ( ( $countResult?yes div $qoute ) > $countingQuote ) then ( "принято" ) else ( "не принято" )
            let $class := if ( $result = "принято" ) then ( "table-success" ) else ( "table-danger" )
            return
              <tr class="{ $class }">
                <td>{$i/text()}</td>
                <td class="text-center">{ $countResult?yes }</td>
                <td class="text-center">{ $countResult?no }</td>
                {
                  if ( $isNeutral )
                  then (
                    <td class="text-center">{ $countResult?neutral }</td>
                  )
                  else ()
                } 
                <td class="text-center">{ $result }</td>
              </tr>
          }
          </tbody>
        </table>
      <hr/>  
    </div>
  
  return
      $data:mainTemlate update replace node .//toreplace with $content
};

declare function view:countResult ( $data, $question ) {
  if ( $data/@type = "multi" )
  then (
    let $yes := count( $data/results/result/question[ @id = $question/@id and @value="yes" ] )
    let $no := count( $data/results/result/question[ @id = $question/@id and @value="no" ] )
    let $neutral := count( $data/results/result/question[ @id = $question/@id and @value="neutral" ] )
    return 
      map { "yes" : $yes, "no" : $no, "neutral" : $neutral }
  )
  else (
    let $yes := count ($data/results/result/question[@value= $question/@id ])
    let $neutral := count ($data/results/result/question[@value="neutral"])
    let $no := $data/meta/quote/text() - $yes - $neutral
    return 
      map { "yes" : $yes, "no" : $no, "neutral" : $neutral }
  )
};
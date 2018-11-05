module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $view:db-name := $data:dbName;

declare 
  %rest:path("/golosovalka/master")
  %rest:GET
  %rest:query-param ( "master", "{ $master }")
  %output:method('xhtml')
function view:master ( $master )
{
  let $data :=  $data:vote ( $master )
  return 
  if ( $data )
  then (
    if ( $data:isOpen ( $data ) or not ( $data/meta/quote ) )
    then (
    let $quote := 
      if ( $data/meta/quote/text() ) 
      then ( $data/meta/quote/text() ) 
      else ( "3" )
    let $questions := 
      if ( $data//questions/question/text() ) 
      then ( string-join( $data//questions/question/text(), "; " ) ) 
      else ( "Вопрос1; Вопрос2" )
    let $content :=
        <div class="col">
          <h3>{ $data/meta/title/text() }</h3>
          <p><i>{request:parameter('message')}</i></p>
          <a href="vote?common={$data/@common}">Ссылка для голосования</a>
          <form action="update-vote">
            <div class="form-group">
              <label for="title">Название голосования</label>
              <input 
                type="text" 
                name="title" 
                class="form-control"
                placeholder="Название голосования"
                value="{ $data//meta/title/text() }"/>
            </div>
            <div class="form-group">
              <label for="questions">Вопросы (через точку с запятой)</label>
              <textarea rows="3" name="questions" class="form-control" placeholder="Вопрос1; Вопрос2">
                  { string-join( $data//questions/question/text(), "; " ) }
              </textarea>
            </div>
            <div class="form-group">
              <label for="name">Количество участников</label>
              <input type="number" name="quote" 
              class="col-sm-1 form-control"
              min = "3"
              placeholder="3"
              value="{ $quote }"/>
            </div>
            <input type="text" name="master" value="{$data/@master}" hidden=""/>
            <button type="submit" class="btn btn-primary">Сохранить</button>
          </form>
        </div>
     
     return
         $data:mainTemlate update replace node .//toreplace with $content
    )
    else (
     let $content :=
        <div class="col">
          <p><i>Голосование "{ $data/meta/title/text()}" завершено</i></p>
          <a href="vote?common={ $data/@common/data() }">Результаты голосования</a>
          <form action="delete-vote">
          <input type="text" name="master" value="{$data/@master}" hidden=""/>
            <button type="submit" class="btn btn-primary">Удалить</button>
          </form>
        </div>
      return
         $data:mainTemlate update replace node .//toreplace with $content
    )
  )
  else (
    let $content :=
        <div class="col">
          <p>Такого голосования не существует</p>
        </div>
    return
         $data:mainTemlate update replace node .//toreplace with $content    
  )
}; 
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
    let $content :=
        <div class="col">
          <h3>{ $data/meta/title/text() }</h3>
          <p><i>{request:parameter('message')}</i></p>
          <a href="vote?common={$data/@common}">Ссылка для голосования</a>
          <form action="update-vote">
            <div class="form-group">
              <label for="title">Название голосования</label>
              <input type="text" name="title" 
              class="form-control"
              value="{$data//meta/title/text()}"/>
            </div>
            <div class="form-group">
              <label for="questions">Вопросы (через точку с запятой)</label>
              <textarea rows="3" name="questions" class="form-control">
                  {
                    for $i in 1 to count($data//questions/question)
                    let $sep := if ($i < count($data//questions/question)) then (';') else ('')
                    return $data//questions/question[$i] || $sep
                  }
              </textarea>
            </div>
            <div class="form-group">
              <label for="name">Количество участников</label>
              <input type="number" name="quote" 
              class="col-sm-1 form-control"
              value="{$data/meta/quote/text()}"/>
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
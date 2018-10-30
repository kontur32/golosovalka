module namespace view = "http://www.iro37.ru/golosovalka/view";
import module namespace request = "http://exquery.org/ns/request";

declare variable $view:db-name := "golosovalka-dev"; 

declare 
  %rest:path("/golosovalka/master")
  %rest:GET
  %output:method('xhtml')
function view:master ()
{
  let $data := db:open( $view:db-name , 'data')/data/vote[@master=request:parameter('master')]
  let $temlate := doc('main-tpl.html')
  let $content :=
      <div class="col">
        <h3>{$data/meta/title/text()}</h3>
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
            value="{$data//meta/quote/text()}"/>
          </div>
          <input type="text" name="master" value="{$data/@master}" hidden=""/>
          <button type="submit" class="btn btn-primary">Сохранить</button>
        </form>
      </div>
   
   return
       $temlate update replace node .//toreplace with $content
}; 

declare 
  %rest:path("/golosovalka/vote")
  %rest:GET
  %output:method('xhtml')
function view:vote ()
{
  let $data := db:open( $view:db-name , 'data')/data/vote[@common=request:parameter('common')]
  let $temlate := doc('main-tpl.html')
  let $content := 
          <div class="col">
            <h3>{$data//meta/title/text()}</h3>
            <p><i>{request:parameter('message')}</i></p>
            <div class="col">
              <a href="result?common={$data/@common}">Результаты голосования</a>
              <p><i>Голосуют {$data/meta/quote/text()} участника</i></p>
              <p><i>Уже проголосовали {count($data//results/result)} участника</i></p>
            </div>
            <hr/>
            {
              if 
                (count($data//results/result) < $data/meta/quote/data() )
              then
              (
              <form action="update-result" method="get">
                  <div class="form-group">
                    {
                      for $i in $data//questions/question
                      return 
                    
                      <label for="q1" class="form-check">
                          {$i/text()}
                          <div class="form-check">
                              <label class="form-check-label">
                                  <input 
                                  type="radio" 
                                  class="form-check-input" 
                                  name="{$i/@id}" 
                                  value="yes" 
                                  checked=""/> 
                                  За
                              </label>
                          </div>
                          <div class="form-check">
                              <label class="form-check-label">
                                  <input 
                                  type="radio" 
                                  class="form-check-input" 
                                  name="{$i/@id}" 
                                  value="no"/>
                                  Против
                              </label>
                          </div>
                          <hr/>
                      </label>
                      }
                      
                  </div>
                  <input type="text" name="common" value="{$data/@common}" hidden=""/>               
                  <div class="form-group">
                      <button type="submit" class="btn btn-primary">Голосовать</button>
                  </div>
              </form>
            )
            else 
              (
                <p>Голосование закрыто</p>
              )
        }
          </div>
  
  return
      $temlate update replace node .//toreplace with $content
};

declare 
  %rest:path("/golosovalka/result")
  %rest:GET
  %output:method('xhtml')
function view:result ()
{
  let $data := db:open( $view:db-name , 'data')/data/vote[@common=request:parameter('common')]
  let $temlate := doc('main-tpl.html')
  let $content := 
    <div class="col">
      <h3>{$data//meta/title/text()}</h3>
      <div class="col">
        <p><i>Голосовали {count($data//result)} участника</i></p>
        <table class="table">
          <thead>
            <tr>
              <th>Вопрос</th>
              <th>За</th>
              <th>Против</th>
              <th>Результат</th>
            </tr>
          </thead>
          <tbody>
          {
            for $i in $data//questions/question
            let $yes := count($data//results/result/question[@id=$i/@id and @value="yes"])
            let $no := count($data//results/result/question[@id=$i/@id and @value="no"])
            let $result := if ($yes > $no ) then ('принято') else ('не принято')
            let $class := if ($yes > $no ) then ('table-success') else ('table-danger')
            return
              <tr class="{$class}">
                <td>{$i/text()}</td>
                <td>{$yes}</td>
                <td>{$no}</td>
                <td>{$result}</td>
              </tr>
          }
          </tbody>
        </table>
      </div>
      <hr/>  
    </div>
  
  return
      $temlate update replace node .//toreplace with $content
};
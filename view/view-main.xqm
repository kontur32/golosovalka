module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $view:db-name := $data:dbName;
declare variable $view:radio :=
  <div>
    <div>
      <span>Количество ответов:</span>
        <div class="form-check">
          <label class="form-check-label" for="single">
              <input name="type" type="radio" value="single" id="single" checked="true">Один из списка</input>
          </label>
        </div>
        <div class="form-check">
          <label class="form-check-label" for="multi">
              <input name="type" type="radio" value="multi" id="multi">Несколько из списка</input>
          </label>
        </div>
     </div>
    <div>
      <span>Варинаты ответов:</span>
        <div class="form-check">
          <label class="form-check-label" for="yesNo">
              <input name="var" type="radio" value="yesNo" id="yesNo" checked="true">За / Против</input>
          </label>
        </div>
        <div class="form-check">
          <label class="form-check-label" for="neutral">
              <input name="var" type="radio" value="neutral" id="neutral">За / Против / Воздержался</input>
          </label>
        </div>
     </div>       
       <div>
        <span>Способ подсчета голосов:</span>
          <div class="form-check">
            <label class="form-check-label" for="count1">
                <input name="counting" type="radio" value="simple" id="count1" checked="true">Простое большинство</input>
            </label>
          </div>
          <div class="form-check">
            <label class="form-check-label" for="count2">
                <input name="counting" type="radio" value="qualified" id="count2">Квалифицированное большинство</input>
            </label>
          </div>
       </div>
  </div>;

declare 
  %rest:path("/golosovalka")
  %rest:GET
  %output:method('xhtml')
function view:main ()
{
  let $content :=
      <div class="col"> 
        <p>Чтобы создать голосование, нажмите...</p>
        <form action="/golosovalka/create-vote">
            { $view:radio }
            <button class="btn btn-primary">Создать</button>
        </form>
      </div>
   return
       $data:mainTemlate update replace node .//toreplace with $content
};


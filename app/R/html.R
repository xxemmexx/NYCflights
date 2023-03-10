#' @param aFlight character vector containing a number of properties of a flight (sched_dep_time, sched_arr_time...)
#' @param anOrigin string - full name of an airport
#' @param aDestination string - full name of an airport
#'
#' @return string - HTML text that can be directly used as "flight card"
#' 
printFlightCard <- function(aFlight, anOrigin, aDestination) {
  paste0('<h1 style=text-align:center;><b>Vlucht ', 
         aFlight$carrier, " ", aFlight$flight, '</b></h1>
         <span><h3 style=text-align:center;> Kenteken: ', aFlight$tailnum,'</h3></span><br><br>
         
         <h4 style=text-align:left;><i class="fa fa-plane-departure"></i> - Vertrek </h4><br>
         
         <h5><b>Vanaf: ', anOrigin, '</b><br><br>
         Ingepland: ', convertIntegerToTimeLabel(aFlight$sched_dep_time),'<br>
         Vertraging: ', displayDelay(aFlight$dep_delay),'
         <hr>
         <h4 style=text-align:left;><i class="fa fa-plane-arrival"></i> - Aankomst </h4><br>
         <b>In: ', aDestination, '</b><br><br>
         Ingepland: ', convertIntegerToTimeLabel(aFlight$sched_arr_time),'<br>
         Vertraging: ', displayDelay(aFlight$arr_delay),'</h5><br><br><br><br>
         
         Totale afstand: ', displayDistanceInKms(aFlight$distance), '
         
         </h4>')
}

printGreeting <- '<h4><p>Wat fijn dat je er bent! <br><br> In dit dashboard kan je de gegevens van 
alle vluchten vanuit New York voor het jaar 2013 makkelijk bekijken. Onze analysten
hebben hun best gedaan om antwoord te geven op de belangrijkste vragen vanuit de business. <br><br>
<b>Hoe druk is het </b> in de luchthaven van New York? Dit kan je op de tab <em>Vliegvelddrukte</em>
onderzoeken. Je ziet er twee grafiekjes: het ene geeft het aantal passagiers weer terwijl je op
het tweede de relatieve capaciteit van elk vliegveld kunt zien. <br><br>
Wat zijn de bepalende factoren achter <b>vertragingen</b>? Beschouw de grafiekjes die 
onze verschillende analystenteams hebben opgesteld! Een team focusseerde op vertragingen 
tijdens het vertrek, het andere op vertragingen in aankomst. Beide hebben de resultaten 
van hun ML analyse op de tab <em>Vertragingen</em> staan. <br><br> 
Welke <b>destinaties</b> je kan bereiken haal je best uit
het kaartje in <em>Destinaties</em>. <br><br>
En als je nog vragen hebt over <b>individuele vluchten</b>
kan je het tabelletje in <em>Vluchtinformatie</em> raadplegen. <br>
</p> <br>
<p style="text-align:center"><b>Veel plezier!</b></p></h4>'

printTitle <-'<h3 style="text-align:center">Welkom in de NYC Dashboard <h3><br>'

printVertragingText <- '<h4><p><b>Wat bepaald vertraging? </b><br><br> We hebben
twee teams van analysten gevraagd om na te gaan welke parameters vluchtvertragingen
veroorzaken. Ze kwamen met twee verschillende antwoorden. <br><br>

Team A heeft gekeken naar de <em>aankomst</em>vertraging. Deze, beweren zij, is 
vanuit een business perspectief, heel belangrijk want mensen vergeten snel dat 
ze vertraging hadden bij het vertrek maar worden heel erg boos als ze vertraging
hebben bij de aankomst. Vandaar dat het beter is om hier na te kijken. Verder
heeft Team A data van alle vliegvelden gebruikt. <br><br>

Team B daarentegen beweert dat als men eens vertraging heeft geboekt aan het begin
van de reis wordt het moeilijk om deze in te halen. Vandaar dat het zinvoller is
om te kijken welke factoren de <em>vertreks</em>vertraging be??nvloeden om iets
te veranderen. Daarenboven
ging Team B ervan uit dat er verschillen zouden kunnen ontstaan tussen het ene en het andere 
vliegveld en deze willen ze graag onderzoeken. <br>
</p> <br></p></h4>'
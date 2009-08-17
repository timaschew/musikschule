# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  $TIMETABLESTART = 13
  $TIMETABLEEND = 21 - $TIMETABLESTART
  
  # Farben für Tabellenhintergrundzellen
  $TABLE_COLOR = []
  $TABLE_COLOR[0] = "#FA5858" # rot
  $TABLE_COLOR[1] = "#F4FA58" # gelb
  $TABLE_COLOR[2] = "#58FA58" # dunkelgrün
  $TABLE_COLOR[3] = "#58ACFA" # hellblau
  $TABLE_COLOR[4] = "#AC58FA" # violet
  $TABLE_COLOR[5] = "#A4A4A4" # grau
  $TABLE_COLOR[6] = "#FAAC58" # orange
  $TABLE_COLOR[7] = "#ACFA58" # hellgrün
  $TABLE_COLOR[8] = "#58FAF4" # türkis
  $TABLE_COLOR[9] = "#5858FA" # dunkelblau
  $TABLE_COLOR[10] = "#FA58F4" # pink
  
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

end

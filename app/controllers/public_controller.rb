class PublicController < ApplicationController
  before_action :set_calendar, only: [:calendar, :pie_data]

  def index
  end

  def calendar
    @timeline_events = build_timeline @calendar.events
    @current_event = get_current_event @calendar.events.current_event.first
  end

  def pie_data
    starts_at = '2014-01-01'.to_date #Event.asc(:starts_at).limit(1).first.starts_at.to_date
    ends_at = '2015-01-01'.to_date #Event.desc(:ends_at).limit(1).first.ends_at.to_date

    ev = { e1: [], e2: [] }
    @calendar.events.where(:holder => 1).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| ev[:e1] << i }
    @calendar.events.where(:holder => 2).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| ev[:e2] << i }

    events = { e1: [], e2: [] }

    events[:e1] = build_pie starts_at, ends_at, ev[:e1]
    events[:e2] = build_pie starts_at, ends_at, ev[:e2]

    render json: { starts_at: starts_at.strftime('%d/%m/%Y'), ends_at: ends_at.strftime('%d/%m/%Y'), days: (ends_at - starts_at) / 3600 / 24 , events1: events[:e1], events2: events[:e2] }
  end

  protected

  def get_current_event event
    return {} if event.nil? || (event.ends_at.to_date - event.starts_at.to_date) == 0
    percent = (Date.current - event.starts_at.to_date).to_f / (event.ends_at.to_date - event.starts_at.to_date).to_f * 100
    { title: event.title, holder_text: event.holder_text, percent: percent}
  end

  def build_pie starts_at, ends_at, ev
    events = []
    end_at = nil
    ev.sort_by { |e| e[:dt] }.map { |e|
      if end_at.nil?
        if e.starts_at > starts_at
          new_ev = { :title => '', :description => '', starts_at: starts_at, ends_at: e.starts_at, color: 'transparent' }
          events << build_event_for_pie(new_ev)
        end
        end_at = starts_at
      elsif end_at < e.starts_at
        new_ev = { :title => '', :description => '', starts_at: end_at, ends_at: e.starts_at, color: 'transparent' }
        events << build_event_for_pie(new_ev)
      elsif end_at > e.starts_at
        e.starts_at = end_at
      end

      end_at = e.ends_at
      events << build_event_for_pie(e)
    }
    if end_at < ends_at
      new_ev = { :title => '', :description => '', starts_at: end_at, ends_at: ends_at, color: 'transparent' }
      events << build_event_for_pie(new_ev)
    end
    events
  end

  def build_event_for_pie event
    days  = (event[:ends_at].to_date - event[:starts_at].to_date).to_i
    #binding.pry
    { label: event[:title], desc: event[:description], starts_at: event[:starts_at].strftime('%d/%m/%Y'), ends_at: event[:ends_at].strftime('%d/%m/%Y'), value: days, color: event[:color], highlight: event[:color] }
  end


  def build_timeline calendar_events
    events = [ ]
    calendar_events.all.map { |i|
      if i.ends_at
        action = i.ends_at > Date.today ? 'закінчиться: ' + i.ends_at.strftime('%d-%m-%Y') : 'закінчилась'
      else
        action = 'одноденна'
      end
      events << { holder: i.holder, dt: i.starts_at, action: action, title: i.title, description: i.description, icon: i.icon, color: i.color, all_day: i.all_day }
    }

    # today = DateTime.now.strftime('%d-%m-%Y')
    # events << { dt: today } unless events.any? {|e| e[:dt] == today }

    events.sort_by { |m| m[:dt] }.reverse!
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

end
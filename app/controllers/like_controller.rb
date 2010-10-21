class LikeController < ApplicationController
  unloadable
    verify :method => :post,
	   :only => [ :like, :unlike ],
           :render => { :nothing => true, :status => :method_not_allowed }

  def like
    if User.current.pref[:others][:issue_like] == nil then 
	User.current.pref[:others][:issue_like]=Array.new
	User.current.pref.save
    end
    if (!User.current.pref[:others][:issue_like].include?(params[:id].to_i)) then
	User.current.pref[:others][:issue_like]+=[params[:issue_id].to_i]
	User.current.pref.save
    end
  end

  def unlike
    if User.current.pref[:others][:issue_like] == nil then 
	User.current.pref[:others][:issue_like]=Array.new
	User.current.pref.save
    end
	User.current.pref[:others][:issue_like]-=[params[:issue_id].to_i]
	User.current.pref.save
  end
  
  def like?
    return User.current.pref[:others][:issue_like].include?(params[:issue_id])
  end
end

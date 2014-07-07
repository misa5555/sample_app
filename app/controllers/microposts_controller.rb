class MicropostsController < ApplicationController
  before_action :signed_in_user, only:[:create, :destroy, :reply]
  before_action :correct_user, only: :destroy
  
  def create
    @micropost = current_user.microposts.build(micropost_params)
    reply_name = extract_reply_to(@micropost.content)
    
    if reply_name != "@"
      @micropost.in_reply_to = User.find_by(name: reply_name).id
    end

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end
  
  def reply
    @replied_user = User.find(params[:user])
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content,:in_reply_to)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
  
    def extract_reply_to(content)
      reply_to = "@"
      if content =~ /\A@(\w+)/
        reply_to = $1.to_s
      end
      reply_to
    end
end

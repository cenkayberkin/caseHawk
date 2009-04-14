# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  name                      :string(255)
#  remember_token            :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  remember_token_expires_at :datetime
#  updated_at                :datetime
#  created_at                :datetime
#  account_id                :integer(8)
#  admin                     :boolean(1)
#

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  should_require_attributes :login
  should_require_attributes :email
  should_require_attributes :password
  should_require_attributes :password_confirmation

  context 'being created' do
    setup do
      @user = create_user
      raise "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
    end

    should_change 'User.count', 1
  end

  should 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  should 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'test')
  end

  should 'authenticates user' do
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  should 'sets remember token' do
    users(:quentin).remember_me
    assert users(:quentin).remember_token
    assert users(:quentin).remember_token_expires_at
  end

  should 'unsets remember token' do
    users(:quentin).remember_me
    assert users(:quentin).remember_token
    users(:quentin).forget_me
    assert_equal nil, users(:quentin).remember_token
  end

  should 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert users(:quentin).remember_token
    assert users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  should 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert users(:quentin).remember_token
    assert users(:quentin).remember_token_expires_at
    assert_equal time, users(:quentin).remember_token_expires_at
  end

  should 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert users(:quentin).remember_token
    assert users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end

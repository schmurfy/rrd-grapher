
FactoryGirl.define do
  factory :data_common, :default_strategy => :build do
    time { Time.now }
    host "localhost"
    plugin "memory"
    plugin_instance nil
    
    type "memory"
    type_instance "active"
  end
  
  factory :data_point, :parent => :data_common, :class => "RRDNotifier::Packet" do
    values { [rand(200)] }
    interval 10
  end
  
  factory :notification, :parent => :data_common, :class => "RRDNotifier::Packet" do
    severity 1
    message "notification message"
  end
  
end

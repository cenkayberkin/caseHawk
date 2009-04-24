Factory.define :tag do |f|
  f.sequence(:name) {|n| "Case Number #{n}" }
end

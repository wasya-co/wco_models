
class Ish::LoremIpsum

  ARR = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a diam pretium, pellentesque lorem consequat, tempus lorem. Morbi et augue mattis, mollis enim et, lobortis ipsum. Aenean ultrices efficitur convallis. Aliquam vel tellus eu orci lobortis rhoncus. Proin varius tellus id pellentesque imperdiet. Donec accumsan diam ut tortor hendrerit pharetra. Duis rhoncus sapien leo, nec tempor massa luctus nec. In venenatis, augue ac pharetra malesuada, erat elit aliquam nisi, ac rutrum nunc purus in odio. Nam mattis vehicula finibus. Vivamus porta, massa nec posuere pulvinar, lacus nisl varius tortor, non fermentum ligula sem at odio. Cras viverra ligula quis elementum gravida. Integer interdum, orci quis varius viverra, neque eros tincidunt ex, quis fringilla quam erat in ex.",
    "Pellentesque consectetur faucibus porta. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque ut orci ut justo rutrum mattis non non turpis. Quisque velit neque, porttitor at lacus quis, ultricies aliquam orci. Morbi finibus neque dolor, vitae convallis leo aliquam in. Nullam posuere urna quis velit mattis, vitae posuere mi elementum. Cras vitae fermentum nisi, sed pretium diam. Donec vestibulum, leo et vehicula pharetra, massa ante vestibulum risus, malesuada pretium metus ipsum eget quam. Nunc feugiat enim elit. Mauris dictum arcu ac nisl placerat, eu cursus tellus malesuada.",
    "Nullam ultrices neque ut ipsum venenatis, et luctus justo aliquet. Nam laoreet magna eget accumsan ultrices. Quisque ut congue velit. Vivamus tincidunt bibendum tincidunt. Cras at purus eget odio consequat porta. Nullam ultricies dolor non dignissim commodo. Nullam cursus est eu mauris pharetra, sed euismod risus bibendum. Nullam quis luctus ante.",
    "Suspendisse cursus quis tellus a dictum. Proin tempus metus nec ultrices egestas. Phasellus imperdiet in ante et bibendum. In aliquam nec sapien vel rutrum. Nunc libero velit, bibendum ac dolor non, interdum fringilla nulla. Aliquam nec lectus nibh. Curabitur non scelerisque tellus, eu viverra ligula. Maecenas euismod sem turpis, ac efficitur velit placerat eget.",
    "Donec faucibus urna a mauris vulputate, quis dignissim turpis venenatis. Phasellus sodales dignissim molestie. Donec ultrices tempor aliquam. Pellentesque sed mi volutpat, euismod erat quis, ultricies enim. Curabitur in nibh eget ipsum fringilla laoreet. Vivamus tincidunt rutrum ullamcorper. Nulla suscipit, libero sit amet blandit venenatis, lorem diam viverra elit, sed egestas elit eros at libero.",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas a diam pretium, pellentesque lorem consequat, tempus lorem. Morbi et augue mattis, mollis enim et, lobortis ipsum. Aenean ultrices efficitur convallis. Aliquam vel tellus eu orci lobortis rhoncus. Proin varius tellus id pellentesque imperdiet. Donec accumsan diam ut tortor hendrerit pharetra. Duis rhoncus sapien leo, nec tempor massa luctus nec. In venenatis, augue ac pharetra malesuada, erat elit aliquam nisi, ac rutrum nunc purus in odio. Nam mattis vehicula finibus. Vivamus porta, massa nec posuere pulvinar, lacus nisl varius tortor, non fermentum ligula sem at odio. Cras viverra ligula quis elementum gravida. Integer interdum, orci quis varius viverra, neque eros tincidunt ex, quis fringilla quam erat in ex.",
    "Pellentesque consectetur faucibus porta. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque ut orci ut justo rutrum mattis non non turpis. Quisque velit neque, porttitor at lacus quis, ultricies aliquam orci. Morbi finibus neque dolor, vitae convallis leo aliquam in. Nullam posuere urna quis velit mattis, vitae posuere mi elementum. Cras vitae fermentum nisi, sed pretium diam. Donec vestibulum, leo et vehicula pharetra, massa ante vestibulum risus, malesuada pretium metus ipsum eget quam. Nunc feugiat enim elit. Mauris dictum arcu ac nisl placerat, eu cursus tellus malesuada.",
    "Nullam ultrices neque ut ipsum venenatis, et luctus justo aliquet. Nam laoreet magna eget accumsan ultrices. Quisque ut congue velit. Vivamus tincidunt bibendum tincidunt. Cras at purus eget odio consequat porta. Nullam ultricies dolor non dignissim commodo. Nullam cursus est eu mauris pharetra, sed euismod risus bibendum. Nullam quis luctus ante.",
    "Suspendisse cursus quis tellus a dictum. Proin tempus metus nec ultrices egestas. Phasellus imperdiet in ante et bibendum. In aliquam nec sapien vel rutrum. Nunc libero velit, bibendum ac dolor non, interdum fringilla nulla. Aliquam nec lectus nibh. Curabitur non scelerisque tellus, eu viverra ligula. Maecenas euismod sem turpis, ac efficitur velit placerat eget.",
    "Donec faucibus urna a mauris vulputate, quis dignissim turpis venenatis. Phasellus sodales dignissim molestie. Donec ultrices tempor aliquam. Pellentesque sed mi volutpat, euismod erat quis, ultricies enim. Curabitur in nibh eget ipsum fringilla laoreet. Vivamus tincidunt rutrum ullamcorper. Nulla suscipit, libero sit amet blandit venenatis, lorem diam viverra elit, sed egestas elit eros at libero.",
  ]


  def self.txt n=3
    ARR[0...3].join("\n\n")
  end

  private

  def self.html n=3
    "<p>#{ARR[0...n].join("</p><p>")}</p>"
  end


end


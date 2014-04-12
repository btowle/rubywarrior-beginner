module BeginnerBehavior
  def get_behavior
    player = self

    BehaviorTree.build {
      #choose target
      until_success {
        until_failure {
          condition { player.closest_target(:behind)[:distance] < player.closest_target(:ahead)[:distance] }
          condition { player.closest_target(:ahead)[:type] != :archer }
          action { player.set_target :behind }
          action { player.change_direction }
        }
        action { player.set_target :ahead }
      }

      action { player.look_behind }

      until_success {
        #rescue
        until_failure {
          condition { player.facing? :captive }
          action { player.save! }
        }

        #melee
        until_failure {
          condition { player.facing? :enemy }
          until_success{
            until_failure {
              condition { player.ready_for_melee? }
              action { player.combat! :melee }
            }
            action { player.about_face! }
          }
        }

        #rest
        until_failure {
          condition { player.weak? }
          condition { player.alone? }
          action { player.heal! }
        }

        #shoot
        until_failure {
          condition { player.ranged_target? }
          action { player.combat! :ranged }
        }

        #walk
        until_success {
          #change direction at walls
          until_failure {
            condition { player.at? :wall }
            condition { !player.at? :stairs }
            action { player.change_direction }
            until_success {
              until_failure {
                condition { player.ranged_target? }
                action { player.combat! :ranged }
              }
              action { player.advance! }
            }
          }
          #retreat if we need to
          until_failure {
            condition { player.in_danger? }
            condition { player.can_fight? }
            condition { player.facing? :wall }
            action { player.retreat! }
          }
          #don't finish if we haven't cleared level
          until_failure {
            condition { player.at? :stairs }
            condition { !player.cleared? }
            action { player.change_direction }
            action { player.advance! }
          }

          #walk
          action { player.advance! }
        }
      }
    }
  end
end

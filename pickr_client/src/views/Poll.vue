<template>
  <div>
    <h1>{{ poll.question }}</h1>
    <div v-for="(item, index) of poll.options" :key="index">
      <Checkbox v-model="selected_options" :value="item.id">{{
        item.value
      }}</Checkbox>
    </div>
 
    <div v-if="isLoading">
      Checking for vote existence...
    </div>
    <div v-else>
         <div v-if="poll_expired">Expired</div>
         <div v-else-if="already_voted">
            <h2>You already voted in this poll!</h2>
         </div>
        <Button v-else @click="castVote">Vote</Button>
        <router-link :to="{name: 'Result', params: {id: poll.id}}">View result </router-link>
    </div>
  </div>
</template>

<script>
import { Socket } from "../channels";
import { castVote, checkVoteExist, fetchPoll, getVoterIp } from "../services/poll";
export default {
  data() {
    return {
      poll: {},
      selected_options: [],
      ip: "",
      channel: null,
      already_voted: false,
      isLoading: false,
      poll_expired: true
    };
  },

  beforeRouteEnter(to, from, next) {
    fetchPoll(to.params.id)
      .then(({ data }) => {
        next((vm) => {
          vm.poll = data;
        });
      })
      .catch(() => {
        next("/404");
      });
  },

  created() {
    this.isLoading = true
    getVoterIp()
      .then((ip) => {
        
        this.ip = ip;
        checkVoteExist(this.poll.id, ip)
          .then(({already_voted}) => {
             this.isLoading = false
            this.already_voted = already_voted
          }
          )
      })
      .catch((error) => {
        this.isLoading = false;
        console.log(error);
      });
  },

  mounted() {
    Socket.findChannel(this.poll.id).then(
      ({ channel }) => (this.channel = channel)
    );
  },
  methods: {
    castVote() {
      if (
        !this.poll.allow_multiple_choice &&
        this.selected_options.length > 1
      ) {
        this.$Message["error"]("Please select one option.");
        return;
      }

      if (
        this.selected_options.length == 0
      ) {
        this.$Message["error"]("Please select an option.");
        return;
      }

      const options = this.selected_options.map((option) => {
        let tmpObj = {};
        tmpObj["poll_id"] = this.poll.id;
        tmpObj["option_id"] = option;
        return tmpObj;
      });

      const formData = { vote: {
        poll_id: this.poll.id,
        ip: this.ip,
        options: options
      } };

      castVote(this.poll.id, formData)
        .then(() => {
          this.channel.push("new_vote", this.poll.id);
          this.$Message("Vote has been cast!");
          this.$router.push(`/poll/${this.poll.id}/result`);
        })
        .catch((error) => this.$Message["error"](error));
    },

    check_poll_expiry(end_date) {
      const poll_end_date = new Date(end_date);
      const today = new Date();
      this.poll_expired = today > poll_end_date
    }
  
    
  }
};
</script>

<style></style>

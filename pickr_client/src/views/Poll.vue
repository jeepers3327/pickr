<template>
  <div class="flex flex-col items-center w-full pt-12">
        <h1 class="text-5xl">{{ poll.question }}</h1>
        <div class=" flex flex-col">
 

    <div v-for="(item, index) of poll.options" :key="index" >
        <div class="flex flex-row rounded-b lg:rounded-b-none lg:rounded-r p-4  justify-between leading-normal card mb-5" @click="selectChoice(item.id)" >
    <Checkbox class="mr-5" v-model="selected_options" :value="item.id">{{
        item.value 
      }}</Checkbox>
  </div>
      
    </div>
 
    <div v-if="isLoading">
      Checking for vote existence...
    </div>
    <div v-else>
         <div v-if="poll_expired">Expired</div>
         <div v-else-if="already_voted">
            <h2>You already voted in this poll!</h2>
         </div>
        <div  v-width="250" v-else>
          <Button color="primary" class="font-bold" size="l" v-width="100"  @click="castVote">Vote</Button>
        </div>
        <div class="pt-5">
           <router-link :to="{name: 'Result', params: {id: poll.id}}">View result </router-link>
        </div>
    </div>
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
          vm.check_poll_expiry(data.end_date);
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
      const day = today.getDate() <= 9 ? '0' + today.getDate() : today.getDate()
      const month = today.getMonth() + 1;
      const year = today.getFullYear();
      const formatted_date = year + "-" + month + "-" + day;
      const today_date = new Date(formatted_date)
      this.poll_expired = today_date > poll_end_date
    },

    selectChoice(choiceId) {
      console.log(choiceId);
      if (this.selected_options.includes(choiceId)) {
        const updated_selected_options = this.selected_options.filter(option => option !== choiceId);
        this.selected_options = updated_selected_options;
      } else {
        this.selected_options.push(choiceId)
      }
    }
  
    
  }
};
</script>

<style>

.card{
    background: #fff;
    box-shadow: 0 6px 10px rgba(0,0,0,.08), 0 0 6px rgba(0,0,0,.05);
      transition: .3s transform cubic-bezier(.155,1.105,.295,1.12),.3s box-shadow,.3s -webkit-transform cubic-bezier(.155,1.105,.295,1.12);
  padding: 14px 80px 18px 36px;
  cursor: pointer;
  min-width: 20rem;
}

.card:hover{
     transform: scale(1.05);
  box-shadow: 0 10px 20px rgba(0,0,0,.12), 0 4px 8px rgba(0,0,0,.06);
}
</style>

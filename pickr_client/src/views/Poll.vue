<template>
  <div>
    <h1>{{ poll.question }}</h1>
    <div v-for="(item, index) of poll.options" :key="index">
      <Checkbox v-model="selected_options" :value="item.id">{{
        item.value
      }}</Checkbox>
    </div>
    <Button @click="castVote">Vote</Button>
  </div>
</template>

<script>
import { Socket } from "../channels";
import { castVote, fetchPoll, getVoterIp } from "../services/poll";
export default {
  data() {
    return {
      poll: {},
      selected_options: [],
      ip: "",
      channel: null,
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

  mounted() {
    getVoterIp()
      .then((ip) => {
        this.ip = ip;
      })
      .catch((error) => {
        console.log(error);
      });

    Socket.findChannel(this.poll.id).then(
      ({ channel }) => (this.channel = channel)
    );
  },
  methods: {
    castVote() {
      if (this.selected_options.length > 1) {
        this.$Message["error"]("Please select one option.");
        return;
      }

      const data = this.selected_options.map((option) => {
        let tmpObj = {};
        tmpObj["poll_id"] = this.poll.id;
        tmpObj["option_id"] = option;
        return tmpObj;
      });

      const formData = { vote: data };

      castVote(this.poll.id, formData)
        .then(() => {
          this.channel.push("new_vote", this.poll.id);
          this.$Message('Vote has been cast!')
          this.$router.push(`/poll/${this.poll.id}/result`)
        })
        .catch((error) => this.$Message["error"](error));
    },
  },
};
</script>

<style></style>

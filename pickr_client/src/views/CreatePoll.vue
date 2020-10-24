<template>
  <div v-width="450">
    <Form
      ref="form"
      :validOnChange="validOnChange"
      :rules="validationRules"
      :model="model"
      id="create_poll"
    >
      <FormItem prop="question" :label="'Question'">
         <textarea  id="poll_question" v-autosize v-model="model.question" rows=5 placeholder="Poll question"></textarea>
      </FormItem>
            <div>
        <FormItem v-for="(item, index) of model.options" :key="index" :label="'Option'+(index+1)" :prop="'options['+index+'].value'">
          <Row type="flex">
            <Cell class="flex1">
            <input type="text" v-model="item.value" placeholder="Option" />
            </Cell>
            <Cell class="text-right" v-width="50">
            <Poptip @confirm="remove(index)" content="Confirm delete?">
              <Button text-color="red" :no-border="true" icon="h-icon-trash"></Button>
            </Poptip>
            </Cell>
          </Row>
        </FormItem>
      </div>
      <FormItem class="button-wrapper add" single>
        <Button size="s" text-color="blue" style="display: flex;" @click="add">Add more options</Button>
      </FormItem>
      <FormItem>
        <DatePicker :format="'yyyy-MM-dd'" v-model="model.end_date" placeholder="Poll end date" :readonly="true" :option="date_setting" ></DatePicker>
      </FormItem>
       <FormItem>
        <Checkbox v-model="model.allow_multiple_choice" style="margin-right: 10px;">Allow multiple poll answers&nbsp;</Checkbox>
        <Checkbox v-model="model.allow_single_vote_only" >One vote per IP Address</Checkbox>
      </FormItem>

      <FormItem class="button-wrapper submit">
        <Button color="primary" :loading="isLoading" @click="submit">Create your poll</Button>&nbsp;&nbsp;&nbsp;
      </FormItem>
    </Form>
  </div>
</template>
<script>
import { createPoll } from '../services/poll';
export default {
  data() {
    return {
      isLoading: false,
      model: {
        question: '', 
        options: [
          {value: ''},
          {value: ''}
        ],
        end_date: '',
        ip: '',
        allow_multiple_choice: false,
        allow_single_vote_only: false
      },
      date_setting: {
        start: new Date()
      },
      validationRules: {
        required: ['question', 'options[].value']
      },
      validOnChange: true 
    };
  },
  methods: {
    async submit() {
      this.isLoading = true;
      let validResult = this.$refs.form.valid();
      if (validResult.result) {
         const formData = {
           "poll": this.model
         };

         
        setTimeout(() => {
          this.isLoading = false;
        }, 1000);
        
        createPoll(formData)
          .then(({data}) => {
            this.$router.push(`/poll/${data.id}`)
          })
          .catch(error => {
            this.$Message['error'](error)
            this.isLoading = false;
          })


      } else {
        this.$Message['error']('Please input the required fields.')
        this.isLoading = false;
      }
    },
    reset() {
      this.$refs.form.resetValid();
    },

    add() {
      this.model.options.push({ value: '' });
    },

    remove(index) {
      if (this.model.options.length < 3) {
        this.$Message['error']('Poll should have minimum of 2 options.');
        return;
      }
      this.model.options.splice(index, 1);
    }
  }
};
</script>

<style>
#create_poll .h-form-item-label {
  display: none;
}

#create_poll input[type="text"] {
  size: 50px;
}

#poll_question {
  resize: none;
}

#poll_question::placeholder {
  font-size: 1.2rem;
}

.button-wrapper {
  display:flex;
  flex-direction: row;
}

.add {
  justify-content: flex-start;
}

.submit {
  justify-content: flex-end;
}

</style>
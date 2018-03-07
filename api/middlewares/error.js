const error = function *(next){
    try{
        yield * next;
    }catch (e) {
        this.body = {status:e.status,
                    message:e.message};
    }
};

module.exports = error;